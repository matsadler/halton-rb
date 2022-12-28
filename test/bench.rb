require "benchmark/ips"
require_relative "../lib/halton"

def halton_number(base, index)
  factor = 1.0
  result = 0.0
  while index > 0
    factor /= base
    result += factor * (index % base)
    index /= base
  end
  result
end

n = 1_000_000
base = 17
Benchmark.ips do |x|
  x.report("ruby") do
    n.times {|i| halton_number(base, i) }
  end

  x.report("number") do
    n.times {|i| Halton.number(base, i) }
  end

  x.report("each") do
    i = 0
    Halton.each(base) do |_|
      i += 1
      break if i > n
    end
  end

  x.report("take") do
    Halton.each(base).take(n)
  end

  x.report("next") do
    s = Halton::Sequence.new(base)
    n.times {|i| s.next }
  end

  x.compare!
end
