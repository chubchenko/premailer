# frozen_string_literal: true

# =============================================================================
# Memory Profiler — detailed object allocation analysis per adapter
#
# Usage:
#   bundle exec ruby memory_profile.rb
#   bundle exec ruby memory_profile.rb --fixture complex_css
#   bundle exec ruby memory_profile.rb --adapter nokogiri_fast --top 30
#
# Writes full MemoryProfiler reports to results/memory_<adapter>_<fixture>.txt
# =============================================================================

require 'bundler/setup'
require 'memory_profiler'
require 'premailer'
require 'optparse'

require_relative 'fixtures'

options = { fixture: :medium, top: 20, adapters: [:nokogiri, :nokogiri_fast, :nokogumbo] }
OptionParser.new do |opts|
  opts.on('--fixture NAME') { |v| options[:fixture] = v.to_sym }
  opts.on('--adapter NAME') { |v| options[:adapters] = [v.to_sym] }
  opts.on('--top N', Integer) { |v| options[:top] = v }
end.parse!

FileUtils.mkdir_p('results')

PREMAILER_OPTIONS = {
  with_html_string: true,
  warn_level: Premailer::Warnings::NONE,
  create_shorthands: true,
  drop_unmergeable_css_rules: false
}.freeze

html = Fixtures::ALL[options[:fixture]]
raise ArgumentError, "Unknown fixture: #{options[:fixture]}" unless html

puts "\nMemory Profiler"
puts "Fixture: #{options[:fixture]} (#{html.bytesize / 1024} KB)"
puts "=" * 65

# ---------------------------------------------------------------------------
# Summary table across all adapters
# ---------------------------------------------------------------------------
puts format("\n%-20s %12s %14s %15s %15s", adapter, alloc_kb, retained_kb, alloc_objects, retained_objects)
puts "─" * 80

options[:adapters].each do |adapter|
  report = MemoryProfiler.report do
    p = Premailer.new(html, PREMAILER_OPTIONS.merge(adapter: adapter))
    p.to_inline_css
    p.cleanup!
  end

  puts format("%-20s %10d KB  %12d KB  %13d  %13d", adapter, report.total_allocated_memsize / 1024, report.total_retained_memsize / 1024, report.total_allocated, report.total_retained)

  # Save full report
  out_path = "results/memory_#{adapter}_#{options[:fixture]}.txt"
  File.open(out_path, 'w') { |f| report.pretty_print(to_file: f, detailed_report: true, scale_bytes: true) }
  puts "  → Full report: #{out_path}"
end

# ---------------------------------------------------------------------------
# Detailed top allocators for nokogiri_fast (usually the most interesting)
# ---------------------------------------------------------------------------
adapter = options[:adapters].include?(:nokogiri_fast) ? :nokogiri_fast : options[:adapters].first
puts "\n\nTop #{options[:top]} allocating locations (#{adapter}, fixture: #{options[:fixture]}):"
puts "─" * 65

report = MemoryProfiler.report do
  p = Premailer.new(html, PREMAILER_OPTIONS.merge(adapter: adapter))
  p.to_inline_css
  p.cleanup!
end

puts "\n  BY MEMORY (allocated bytes):"
report.allocated_memory_by_location
  .first(options[:top])
  .each_with_index do |(location, bytes), i|
  puts "  #{format('%2d', i + 1)}. #{format('%8d', bytes)} B  #{location}"
end

puts "\n  BY OBJECT COUNT:"
report.allocated_objects_by_location
  .first(options[:top])
  .each_with_index do |(location, count), i|
  puts "  #{format('%2d', i + 1)}. #{format('%6d', count)} objects  #{location}"
end

puts "\n  TOP ALLOCATED TYPES:"
report.allocated_memory_by_class
  .first(15)
  .each_with_index do |(klass, bytes), i|
  puts "  #{format('%2d', i + 1)}. #{format('%8d', bytes)} B  #{klass}"
end

puts "\nDone.\n"
