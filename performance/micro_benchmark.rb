# frozen_string_literal: true

# =============================================================================
# Micro-benchmark: Isolates specific hotspot methods in Premailer
#
# Usage:
#   bundle exec ruby micro_benchmark.rb
#
# What this measures:
#   1. CSS loading overhead (load_css_from_html!)
#   2. CSS rule merging per element (specificity resolution)
#   3. Link conversion overhead (convert_inline_links)
#   4. cleanup! vs GC-only memory release
#   5. YAML client_support loading (check_client_support)
# =============================================================================

require 'bundler/setup'
require 'benchmark/ips'
require 'premailer'
require 'nokogiri'

require_relative 'fixtures'

ADAPTERS = [:nokogiri, :nokogiri_fast, :nokogumbo].freeze

PREMAILER_BASE_OPTIONS = {
  with_html_string: true,
  warn_level: Premailer::Warnings::NONE
}.freeze

separator = lambda { |title|
  puts "\n#{'─' * 65}"
  puts "  #{title}"
  puts '─' * 65
}

# =============================================================================
# 1. Full pipeline — to_inline_css per adapter, all fixtures
# =============================================================================
separator.call("Full pipeline: to_inline_css across all fixtures")

Fixtures::ALL.each do |fixture_name, html|
  puts "\n[#{fixture_name}] — #{html.bytesize / 1024} KB"
  Benchmark.ips do |x|
    x.config(time: 10, warmup: 3)
    ADAPTERS.each do |adapter|
      x.report(adapter.to_s) do
        p = Premailer.new(html, PREMAILER_BASE_OPTIONS.merge(adapter: adapter))
        p.to_inline_css
        p.cleanup!
      end
    end
    x.compare!
  end
end

# =============================================================================
# 2. Isolate: to_plain_text (uses @doc, exercises convert_to_text)
# =============================================================================
separator.call("Isolated: to_plain_text (plain text generation only)")

html = Fixtures::MEDIUM

Benchmark.ips do |x|
  x.config(time: 10, warmup: 3)
  ADAPTERS.each do |adapter|
    x.report(adapter.to_s) do
      p = Premailer.new(html, PREMAILER_BASE_OPTIONS.merge(adapter: adapter))
      p.to_plain_text
      p.cleanup!
    end
  end
  x.compare!
end

# =============================================================================
# 3. Isolate: HTML loading only (load_html)
# =============================================================================
separator.call("Isolated: HTML loading (load_html) — no CSS processing")

html = Fixtures::LARGE
options_no_css = PREMAILER_BASE_OPTIONS.merge(
  adapter: :nokogiri,
  include_link_tags: false,
  include_style_tags: false,
  css_to_attributes: false
)

Benchmark.ips do |x|
  x.config(time: 10, warmup: 3)
  ADAPTERS.each do |adapter|
    x.report(adapter.to_s) do
      p = Premailer.new(html, options_no_css.merge(adapter: adapter))
      p.to_s # just serialise back, no CSS work
      p.cleanup!
    end
  end
  x.compare!
end

# =============================================================================
# 4. create_shorthands: on vs off
# =============================================================================
separator.call("Option impact: create_shorthands true vs false (nokogiri_fast, complex_css)")

html = Fixtures::COMPLEX_CSS

Benchmark.ips do |x|
  x.config(time: 10, warmup: 3)

  x.report("shorthands=true") do
    p = Premailer.new(html, PREMAILER_BASE_OPTIONS.merge(adapter: :nokogiri_fast, create_shorthands: true))
    p.to_inline_css
    p.cleanup!
  end

  x.report("shorthands=false") do
    p = Premailer.new(html, PREMAILER_BASE_OPTIONS.merge(adapter: :nokogiri_fast, create_shorthands: false))
    p.to_inline_css
    p.cleanup!
  end

  x.compare!
end

# =============================================================================
# 5. drop_unmergeable_css_rules: on vs off
# =============================================================================
separator.call("Option impact: drop_unmergeable_css_rules (nokogiri_fast, complex_css)")

Benchmark.ips do |x|
  x.config(time: 10, warmup: 3)

  x.report("drop_unmergeable=false") do
    p = Premailer.new(html, PREMAILER_BASE_OPTIONS.merge(adapter: :nokogiri_fast, drop_unmergeable_css_rules: false))
    p.to_inline_css
    p.cleanup!
  end

  x.report("drop_unmergeable=true") do
    p = Premailer.new(html, PREMAILER_BASE_OPTIONS.merge(adapter: :nokogiri_fast, drop_unmergeable_css_rules: true))
    p.to_inline_css
    p.cleanup!
  end

  x.compare!
end

# =============================================================================
# 6. remove_classes / remove_comments / remove_ids overhead
# =============================================================================
separator.call("Option impact: post-processing flags (nokogiri_fast, large)")

html = Fixtures::LARGE

Benchmark.ips do |x|
  x.config(time: 10, warmup: 3)

  x.report("no cleanup flags") do
    p = Premailer.new(html, PREMAILER_BASE_OPTIONS.merge(
                              adapter: :nokogiri_fast,
                              remove_classes: false, remove_comments: false, remove_ids: false
                            ))
    p.to_inline_css
    p.cleanup!
  end

  x.report("all cleanup flags") do
    p = Premailer.new(html, PREMAILER_BASE_OPTIONS.merge(
                              adapter: :nokogiri_fast,
                              remove_classes: true, remove_comments: true, remove_ids: true
                            ))
    p.to_inline_css
    p.cleanup!
  end

  x.compare!
end

# =============================================================================
# 7. Append query string overhead (many_links fixture)
# =============================================================================
separator.call("Option impact: link_query_string (nokogiri_fast, many_links)")

html = Fixtures::MANY_LINKS

Benchmark.ips do |x|
  x.config(time: 10, warmup: 3)

  x.report("no query string") do
    p = Premailer.new(html, PREMAILER_BASE_OPTIONS.merge(adapter: :nokogiri_fast))
    p.to_inline_css
    p.cleanup!
  end

  x.report("with query string") do
    p = Premailer.new(html, PREMAILER_BASE_OPTIONS.merge(
                              adapter: :nokogiri_fast,
                              link_query_string: 'utm_source=email&utm_medium=newsletter&utm_campaign=spring2024'
                            ))
    p.to_inline_css
    p.cleanup!
  end

  x.compare!
end

# =============================================================================
# 8. cleanup! vs no cleanup (memory leak risk illustration)
# =============================================================================
separator.call("cleanup! impact — 100 consecutive runs, nokogiri_fast")

puts "  Without cleanup! (accumulates native memory):"
t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
100.times do
  Premailer.new(Fixtures::MEDIUM, PREMAILER_BASE_OPTIONS.merge(adapter: :nokogiri_fast)).to_inline_css
end
GC.start
t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
puts "    Total: #{format('%.1f', (t1 - t0) * 1000)} ms"

puts "  With cleanup! (releases libxml2 memory each time):"
t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
100.times do
  p = Premailer.new(Fixtures::MEDIUM, PREMAILER_BASE_OPTIONS.merge(adapter: :nokogiri_fast))
  p.to_inline_css
  p.cleanup!
end
GC.start
t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
puts "    Total: #{format('%.1f', (t1 - t0) * 1000)} ms"

puts "\nDone.\n"
