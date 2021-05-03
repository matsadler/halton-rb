# frozen_string_literal: true

require "test/unit"
require_relative "../lib/halton"

class HaltonTest < Test::Unit::TestCase

  def within_eps(a, b)
    [a.abs, b.abs].min * 0.001 >= (a - b).abs
  end

  def within_eps_ary(a, b)
    a.zip(b).all? {|a, b| within_eps(a, b)}
  end

  def test_number_base_2
    assert { within_eps(Halton.number(2, 0), 0.0) }
    assert { within_eps(Halton.number(2, 1), 0.5) }
    assert { within_eps(Halton.number(2, 2), 0.25) }
    assert { within_eps(Halton.number(2, 3), 0.75) }
    assert { within_eps(Halton.number(2, 4), 0.125) }
    assert { within_eps(Halton.number(2, 5), 0.625) }
    assert { within_eps(Halton.number(2, 6), 0.375) }
    assert { within_eps(Halton.number(2, 7), 0.875) }
    assert { within_eps(Halton.number(2, 8), 0.0625) }
    assert { within_eps(Halton.number(2, 9), 0.5625) }
  end

  def test_number_base_3
    assert { within_eps(Halton.number(3, 0), 0.0) };
    assert { within_eps(Halton.number(3, 1), 0.3333333333333333) };
    assert { within_eps(Halton.number(3, 2), 0.6666666666666666) };
    assert { within_eps(Halton.number(3, 3), 0.1111111111111111) };
    assert { within_eps(Halton.number(3, 4), 0.4444444444444444) };
    assert { within_eps(Halton.number(3, 5), 0.7777777777777777) };
    assert { within_eps(Halton.number(3, 6), 0.2222222222222222) };
    assert { within_eps(Halton.number(3, 7), 0.5555555555555555) };
    assert { within_eps(Halton.number(3, 8), 0.8888888888888888) };
    assert { within_eps(Halton.number(3, 9), 0.0370370370370370) };
  end

  def test_enum_base_2
    enum = Halton.each(2)

    assert { within_eps(enum.next, 0.5) }
    assert { within_eps(enum.next, 0.25) }
    assert { within_eps(enum.next, 0.75) }
    assert { within_eps(enum.next, 0.125) }
    assert { within_eps(enum.next, 0.625) }
    assert { within_eps(enum.next, 0.375) }
    assert { within_eps(enum.next, 0.875) }
    assert { within_eps(enum.next, 0.0625) }
    assert { within_eps(enum.next, 0.5625) }
  end

  def test_enum_base_3
    enum = Halton.each(3)

    assert { within_eps(enum.next, 0.3333333333333333) }
    assert { within_eps(enum.next, 0.6666666666666666) }
    assert { within_eps(enum.next, 0.1111111111111111) }
    assert { within_eps(enum.next, 0.4444444444444444) }
    assert { within_eps(enum.next, 0.7777777777777777) }
    assert { within_eps(enum.next, 0.2222222222222222) }
    assert { within_eps(enum.next, 0.5555555555555555) }
    assert { within_eps(enum.next, 0.8888888888888888) }
    assert { within_eps(enum.next, 0.0370370370370370) }
  end

  def test_each_2d
    enum = Halton.each(2, 3)

    assert { within_eps_ary(enum.next, [0.5, 0.3333333333333333]) }
    assert { within_eps_ary(enum.next, [0.25, 0.6666666666666666]) }
    assert { within_eps_ary(enum.next, [0.75, 0.1111111111111111]) }
    assert { within_eps_ary(enum.next, [0.125, 0.4444444444444444]) }
    assert { within_eps_ary(enum.next, [0.625, 0.7777777777777777]) }
    assert { within_eps_ary(enum.next, [0.375, 0.2222222222222222]) }
    assert { within_eps_ary(enum.next, [0.875, 0.5555555555555555]) }
    assert { within_eps_ary(enum.next, [0.0625, 0.8888888888888888]) }
    assert { within_eps_ary(enum.next, [0.5625, 0.0370370370370370]) }
  end

end
