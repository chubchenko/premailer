# Premailer Adapter Benchmark Suite

A comprehensive benchmark suite comparing the `nokogiri`, `nokogiri_fast`, and `nokogumbo`
adapters across multiple realistic HTML fixture sizes and complexity profiles.

---

## Setup

```bash
bundle install
mkdir -p results
```

---

## Files

| File | Purpose |
|------|---------|
| `benchmark.rb` | Main runner: IPS + wall-clock timing + memory per fixture |
| `micro_benchmark.rb` | Isolates individual hotspot methods and option flags |
| `memory_profile.rb` | Detailed object allocation reports via `memory_profiler` |
| `fixtures.rb` | Five HTML fixtures of varying size and complexity |
| `reporters/console_reporter.rb` | Pretty terminal table output |
| `reporters/csv_reporter.rb` | CSV output for spreadsheet analysis |

---

## Fixtures

| Name | Size | What it stresses |
|------|------|-----------------|
| `small` | ~4 KB | Baseline; simple newsletter |
| `medium` | ~18 KB | Table-heavy transactional email, 20 line items |
| `large` | ~60 KB | 40 product cards, many selectors, large DOM |
| `complex_css` | ~25 KB | 80 CSS selectors, shorthand expansion, specificity conflicts, media queries |
| `many_links` | ~22 KB | 100 rows × 4 links/images; stresses `convert_inline_links` |

---

## Usage

### Full benchmark (all adapters, all fixtures)
```bash
bundle exec ruby benchmark.rb
```

### Faster run for a quick check
```bash
bundle exec ruby benchmark.rb --iterations 10 --warmup 2
```

### Single adapter or fixture
```bash
bundle exec ruby benchmark.rb --adapter nokogiri_fast --fixture complex_css
```

### CSV output (for charting in Excel/Google Sheets)
```bash
bundle exec ruby benchmark.rb --format csv
# → results/benchmark_results.csv
```

### Micro-benchmarks (option flags, isolated methods)
```bash
bundle exec ruby micro_benchmark.rb
```

### Detailed memory profiling
```bash
bundle exec ruby memory_profile.rb
bundle exec ruby memory_profile.rb --fixture large --top 30
bundle exec ruby memory_profile.rb --adapter nokogiri_fast --fixture complex_css
```

---

## What to expect

### Throughput (IPS)
`nokogiri_fast` is typically **10–20× faster** than `nokogiri` on medium-to-large HTML,
because it builds an in-memory element index keyed by selector before applying rules,
reducing repeated DOM traversals from O(rules × elements) to closer to O(rules + elements).

`nokogumbo` is similar to `nokogiri` in throughput but uses a different HTML5-compliant
parser (Google's Gumbo), which may handle malformed HTML differently.

### Memory
`nokogiri_fast`'s speed trade-off is higher memory usage. It pre-builds hash maps of
elements per selector, so peak allocated memory can be **2–4× higher** than `nokogiri`
on large documents. Retained memory after `cleanup!` should converge across adapters.

### Key option interactions (from micro_benchmark.rb)
- `create_shorthands: false` typically saves **5–15%** wall time
- `drop_unmergeable_css_rules: true` saves time proportional to unmergeable rule count
- `link_query_string` adds overhead linear in the number of `<a>` tags
- Always call `cleanup!` in long-running processes (Sidekiq, Puma) to release
  libxml2 native memory that Ruby's GC cannot see

---

## Results directory

All runs write output to `./results/`:

- `benchmark_YYYYMMDD_HHMMSS.txt` — full console report
- `benchmark_results.csv` — CSV (overwritten each CSV-format run)
- `memory_<adapter>_<fixture>.txt` — full MemoryProfiler report per adapter

---

## Interpreting results

A typical summary looks like:

```
Fixture: LARGE
┼──────────────────────┼──────────┼──────────┼──────────┼──────────┼───────────────────┼
│  Adapter             │  Avg     │  Min     │  Max     │  StdDev  │  vs slowest       │
┼──────────────────────┼──────────┼──────────┼──────────┼──────────┼───────────────────┼
│  nokogiri            │  240.3ms │  231.1ms │  261.2ms │   8.7ms  │  baseline         │
│  nokogiri_fast       │   14.1ms │   13.5ms │   16.8ms │   0.9ms  │  17.0x faster     │
│  nokogumbo           │  238.6ms │  228.9ms │  258.4ms │   9.1ms  │  1.0x faster      │
┼──────────────────────┼──────────┼──────────┼──────────┼──────────┼───────────────────┼
```

(Actual numbers will vary by hardware and Ruby version.)
