# frozen_string_literal: true

require 'csv'

# =============================================================================
# CsvReporter — writes results to a CSV file for analysis in spreadsheets
# =============================================================================
class CsvReporter
  CSV_PATH = 'results/benchmark_results.csv'

  def initialize(results)
    @results = results
    FileUtils.mkdir_p('results')
  end

  def report
    CSV.open(CSV_PATH, 'w') do |csv|
      csv << [
        'fixture', 'adapter', 'avg_ms', 'min_ms', 'max_ms', 'stddev_ms', 'allocated_memsize_kb', 'retained_memsize_kb', 'allocated_objects', 'retained_objects', 'speedup_vs_nokogiri'
      ]

      @results.each do |fixture_name, adapter_data|
        # Compute speedup relative to :nokogiri baseline
        baseline_avg = adapter_data.dig(:nokogiri, :avg_ms) || 1.0

        adapter_data.each do |adapter, metrics|
          avg = metrics[:avg_ms] || 0
          speedup = baseline_avg.positive? ? (baseline_avg / avg).round(2) : nil

          csv << [
            fixture_name,
            adapter,
            format('%.3f', avg),
            format('%.3f', metrics[:min_ms]    || 0),
            format('%.3f', metrics[:max_ms]    || 0),
            format('%.3f', metrics[:stddev_ms] || 0),
            ((metrics[:allocated_memsize] || 0) / 1024),
            ((metrics[:retained_memsize]  || 0) / 1024),
            metrics[:allocated_objects] || 0,
            metrics[:retained_objects]  || 0,
            speedup
          ]
        end
      end
    end

    puts "\nCSV results written to: #{CSV_PATH}"
  end
end
