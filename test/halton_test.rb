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

  def test_each_3d
    enum = Halton.each(2, 3, 5)

    assert { within_eps_ary(enum.next, [0.5, 0.3333333333333333, 0.2]) }
    assert { within_eps_ary(enum.next, [0.25, 0.6666666666666666, 0.4]) }
    assert { within_eps_ary(enum.next, [0.75, 0.1111111111111111, 0.6]) }
    assert { within_eps_ary(enum.next, [0.125, 0.4444444444444444, 0.8]) }
    assert { within_eps_ary(enum.next, [0.625, 0.7777777777777777, 0.04]) }
    assert { within_eps_ary(enum.next, [0.375, 0.2222222222222222, 0.24]) }
    assert { within_eps_ary(enum.next, [0.875, 0.5555555555555555, 0.44000000000000006]) }
    assert { within_eps_ary(enum.next, [0.0625, 0.8888888888888888, 0.64]) }
    assert { within_eps_ary(enum.next, [0.5625, 0.0370370370370370, 0.8400000000000001]) }
  end

  def test_each_4d
    enum = Halton.each(2, 3, 5, 7)

    assert { within_eps_ary(enum.next, [0.5, 0.3333333333333333, 0.2, 0.14285714285714285]) }
    assert { within_eps_ary(enum.next, [0.25, 0.6666666666666666, 0.4, 0.2857142857142857]) }
    assert { within_eps_ary(enum.next, [0.75, 0.1111111111111111, 0.6, 0.42857142857142855]) }
    assert { within_eps_ary(enum.next, [0.125, 0.4444444444444444, 0.8, 0.5714285714285714]) }
    assert { within_eps_ary(enum.next, [0.625, 0.7777777777777777, 0.04, 0.7142857142857143]) }
    assert { within_eps_ary(enum.next, [0.375, 0.2222222222222222, 0.24, 0.8571428571428571]) }
    assert { within_eps_ary(enum.next, [0.875, 0.5555555555555555, 0.44000000000000006, 0.02040816326530612]) }
    assert { within_eps_ary(enum.next, [0.0625, 0.8888888888888888, 0.64, 0.16326530612244897]) }
    assert { within_eps_ary(enum.next, [0.5625, 0.0370370370370370, 0.8400000000000001, 0.30612244897959184]) }
  end
end
