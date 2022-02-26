require "benchmark"
require_relative "../lib/halton"

n = 1_000_000
base = 2
Benchmark.bm(6) do |x|
  x.report("number") do
    n.times {|i| Halton.number(base, i) }
  end

  x.report("each") do
    Halton.each(base).take(n)
  end
end
