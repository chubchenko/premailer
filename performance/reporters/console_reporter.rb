# frozen_string_literal: true

require 'fileutils'
require 'terminal-table'

# =============================================================================
# ConsoleReporter — pretty-prints a summary table to stdout and saves to file
# =============================================================================
class ConsoleReporter
  def initialize(results)
    @results = results
    ::FileUtils.mkdir_p('results')
  end

  def report
    puts "\n\n#{'=' * 70}"
    puts "  BENCHMARK SUMMARY"
    puts "#{'=' * 70}"

    @results.each do |fixture_name, adapter_data|
      puts "\nFixture: #{fixture_name.to_s.upcase.tr('_', ' ')}"

      # Timing table
      timing_rows = adapter_data.map do |adapter, metrics|
        [
          adapter.to_s,
          format('%.1f ms', metrics[:avg_ms] || 0),
          format('%.1f ms', metrics[:min_ms] || 0),
          format('%.1f ms', metrics[:max_ms] || 0),
          format('%.1f ms', metrics[:stddev_ms] || 0),
          format_speedup(adapter, adapter_data)
        ]
      end

      puts Terminal::Table.new(
        headings: ['Adapter', 'Avg', 'Min', 'Max', 'StdDev', 'vs slowest'],
        rows: timing_rows,
        style: { border_x: '─', border_y: '│', border_i: '┼', padding_left: 2, padding_right: 2 }
      )

      # Memory table
      mem_rows = adapter_data.map do |adapter, metrics|
        [
          adapter.to_s,
          format('%d KB',  (metrics[:allocated_memsize] || 0) / 1024),
          format('%d KB',  (metrics[:retained_memsize]  || 0) / 1024),
          format('%d',      metrics[:allocated_objects]  || 0),
          format('%d',      metrics[:retained_objects]   || 0)
        ]
      end

      puts Terminal::Table.new(
        headings: ['Adapter', 'Alloc Mem', 'Retained Mem', 'Alloc Objects', 'Retained Objects'],
        rows: mem_rows,
        style: { border_x: '─', border_y: '│', border_i: '┼', padding_left: 2, padding_right: 2 }
      )
    end

    save_text_report
  end

  private

  def format_speedup(adapter, adapter_data)
    avg = adapter_data[adapter][:avg_ms] || 0
    max_avg = adapter_data.values.map { |m| m[:avg_ms] || 0 }.max
    return 'N/A' if max_avg.zero? || avg.zero?
    speedup = max_avg / avg
    speedup >= 1.05 ? format('%.1fx faster', speedup) : 'baseline'
  end

  def save_text_report
    report_path = "results/benchmark_#{Time.now.strftime('%Y%m%d_%H%M%S')}.txt"
    File.open(report_path, 'w') do |f|
      f.puts "Premailer Adapter Benchmark Report"
      f.puts "Generated: #{Time.now}"
      f.puts "Ruby: #{RUBY_VERSION}"
      f.puts "=" * 70
      f.puts

      @results.each do |fixture_name, adapter_data|
        f.puts "Fixture: #{fixture_name}"
        f.puts "-" * 40

        adapter_data.each do |adapter, metrics|
          f.puts "  #{adapter}:"
          f.puts "    Timing   — avg: #{format('%.2f', metrics[:avg_ms] || 0)} ms, " \
                 "min: #{format('%.2f', metrics[:min_ms] || 0)} ms, " \
                 "max: #{format('%.2f', metrics[:max_ms] || 0)} ms, " \
                 "σ: #{format('%.2f', metrics[:stddev_ms] || 0)} ms"
          f.puts "    Memory   — allocated: #{(metrics[:allocated_memsize] || 0) / 1024} KB, " \
                 "retained: #{(metrics[:retained_memsize] || 0) / 1024} KB"
          f.puts "    Objects  — allocated: #{metrics[:allocated_objects] || 0}, " \
                 "retained: #{metrics[:retained_objects] || 0}"
        end

        f.puts
      end
    end

    puts "\nFull report saved to: #{report_path}"
  end
end
