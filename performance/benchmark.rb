# frozen_string_literal: true

# =============================================================================
# Premailer Adapter Benchmark Suite
# =============================================================================
#
# Usage:
#   bundle exec ruby benchmark.rb
#   bundle exec ruby benchmark.rb --iterations 50
#   bundle exec ruby benchmark.rb --format csv
#   bundle exec ruby benchmark.rb --adapter nokogiri_fast   # single adapter only
#
# Requirements:
#   gem install premailer nokogiri benchmark-ips memory_profiler terminal-table
#   (or use the provided Gemfile)
# =============================================================================

require 'bundler/setup'
require 'benchmark/ips'
require 'memory_profiler'
require 'premailer'
require 'nokogiri'
require 'terminal-table'
require 'optparse'

require_relative 'fixtures'
require_relative 'reporters/console_reporter'
require_relative 'reporters/csv_reporter'

# ---------------------------------------------------------------------------
# CLI options
# ---------------------------------------------------------------------------
options = {
  iterations: 30,
  warmup: 5,
  format: 'console',
  adapters: [:nokogiri, :nokogiri_fast, :nokogumbo],
  fixtures: nil # nil = all
}

OptionParser.new do |opts|
  opts.banner = "Usage: benchmark.rb [options]"
  opts.on('--iterations N', Integer, "IPS measurement time in seconds (default: 30)") { |v| options[:iterations] = v }
  opts.on('--warmup N',     Integer, "IPS warmup time in seconds (default: 5)") { |v| options[:warmup] = v }
  opts.on('--format FMT',            "Output format: console or csv (default: console)") { |v| options[:format] = v }
  opts.on('--adapter NAME',          "Run only this adapter (nokogiri, nokogiri_fast, nokogumbo)") do |v|
    options[:adapters] = [v.to_sym]
  end
  opts.on('--fixture NAME', "Run only this fixture (small, medium, large, complex_css, many_links)") do |v|
    options[:fixtures] = [v.to_sym]
  end
end.parse!

# ---------------------------------------------------------------------------
# Benchmark runner
# ---------------------------------------------------------------------------
class BenchmarkRunner
  PREMAILER_OPTIONS = {
    with_html_string: true,
    warn_level: Premailer::Warnings::NONE,
    drop_unmergeable_css_rules: false,
    create_shorthands: true
  }.freeze

  attr_reader :results

  def initialize(options)
    @options    = options
    @results    = {}
    @adapters   = options[:adapters]
    @fixture_names = options[:fixtures] || Fixtures::ALL.keys
    @iterations = options[:iterations]
    @warmup     = options[:warmup]
  end

  def run
    puts "\n#{'=' * 70}"
    puts "  Premailer Adapter Benchmark Suite"
    puts "  Ruby #{RUBY_VERSION} | #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "  Adapters : #{@adapters.join(', ')}"
    puts "  Fixtures : #{@fixture_names.join(', ')}"
    puts "#{'=' * 70}\n"

    @fixture_names.each do |fixture_name|
      html = Fixtures::ALL[fixture_name]
      raise ArgumentError, "Unknown fixture: #{fixture_name}" unless html

      puts "\n[Fixture: #{fixture_name}] #{html.bytesize / 1024}KB HTML"
      puts '-' * 50

      @results[fixture_name] = {}

      run_ips_benchmark(fixture_name, html)
      run_memory_benchmark(fixture_name, html)
      run_allocation_benchmark(fixture_name, html)
    end

    @results
  end

  private

  # --- Iterations Per Second -------------------------------------------------
  def run_ips_benchmark(fixture_name, html)
    puts "  → Throughput (iterations/sec, higher is better)"

    Benchmark.ips do |x|
      x.config(time: @iterations, warmup: @warmup)

      @adapters.each do |adapter|
        x.report(adapter.to_s) do
          p = Premailer.new(html, PREMAILER_OPTIONS.merge(adapter: adapter))
          p.to_inline_css
          p.cleanup!
        end
      end

      x.compare!

      x.hold! "results/#{fixture_name}_ips_hold"
    end
  rescue StandardError => e
    puts "  IPS benchmark error: #{e.message}"
  end

  # --- Memory Usage ----------------------------------------------------------
  def run_memory_benchmark(fixture_name, html)
    puts "\n  → Memory usage (peak RSS)"

    @adapters.each do |adapter|
      report = MemoryProfiler.report do
        p = Premailer.new(html, PREMAILER_OPTIONS.merge(adapter: adapter))
        p.to_inline_css
        p.cleanup!
      end

      @results[fixture_name][adapter] ||= {}
      @results[fixture_name][adapter][:allocated_memsize] = report.total_allocated_memsize
      @results[fixture_name][adapter][:retained_memsize]  = report.total_retained_memsize
      @results[fixture_name][adapter][:allocated_objects] = report.total_allocated
      @results[fixture_name][adapter][:retained_objects]  = report.total_retained

      puts format("    %-20s  alloc: %6d KB  retained: %4d KB  objects: %7d",
                  adapter,
                  report.total_allocated_memsize / 1024,
                  report.total_retained_memsize  / 1024,
                  report.total_allocated)
    end
  end

  # --- Wall-clock time (simple loop) -----------------------------------------
  def run_allocation_benchmark(fixture_name, html)
    puts "\n  → Wall-clock time (#{TIMING_RUNS} runs, lower is better)"

    @adapters.each do |adapter|
      times = TIMING_RUNS.times.map do
        t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        p = Premailer.new(html, PREMAILER_OPTIONS.merge(adapter: adapter))
        p.to_inline_css
        p.cleanup!
        Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0
      end

      avg  = times.sum / times.size
      min  = times.min
      max  = times.max
      stddev = Math.sqrt(times.map { |t| (t - avg)**2 }.sum / times.size)

      @results[fixture_name][adapter] ||= {}
      @results[fixture_name][adapter][:avg_ms]    = avg * 1000
      @results[fixture_name][adapter][:min_ms]    = min * 1000
      @results[fixture_name][adapter][:max_ms]    = max * 1000
      @results[fixture_name][adapter][:stddev_ms] = stddev * 1000

      puts format("    %-20s  avg: %6.1f ms  min: %5.1f ms  max: %6.1f ms  σ: %4.1f ms",
                  adapter,
                  avg    * 1000,
                  min    * 1000,
                  max    * 1000,
                  stddev * 1000)
    end
  end

  TIMING_RUNS = 20
end

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
runner  = BenchmarkRunner.new(options)
results = runner.run

reporter = case options[:format]
           when 'csv' then CsvReporter.new(results)
           else ConsoleReporter.new(results)
end

reporter.report

puts "\nDone. Results written to ./results/ directory.\n"
