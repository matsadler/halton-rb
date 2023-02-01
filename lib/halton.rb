# frozen_string_literal: true

begin
  /(?<ruby_version>\d+\.\d+)/ =~ RUBY_VERSION
  require_relative "halton/#{ruby_version}/halton"
rescue LoadError
  begin
    require_relative "halton/halton"
  rescue LoadError # Cargo Builder in RubyGems < 3.4.6 doesn't install to dir
    require_relative "halton.so"
  end
end

# The Halton module provides methods for generating Halton sequences, a
# deterministic low discrepancy sequence that appears to be random. The uniform
# distribution and repeatability makes the sequence ideal for choosing sample
# points or placing objects in 2D or 3D space.
#
#   grid = 10.times.map {10.times.map {"."}}
#   Halton.each(2, 3).take(26).zip("A".."Z") do |(x, y), c|
#     grid[y * 10][x * 10] = c
#   end
#   grid.each {|row| puts row.join(" ")}
#
# Outputs:
#
#   . . R . . I . . . .
#   . L . . . . U C . .
#   X . . F . . . . . O
#   . . . J . A . . . .
#   . D . . . . M S . .
#   P . . . V . . . G .
#   . . B . . Y . . . .
#   . T . . . . E . K .
#   H . . . N . . . . W
#   . . . Z . Q . . . .
#
module Halton

  ##
  # :singleton-method: number
  # :call-seq: Halton.number(base, index) -> int
  #
  # Returns the number at +index+ of the Halton sequence for +base+. The number
  # returned will be > 0 and < 1, assuming +index+ > 1.
  #
  # While #each will be faster for most cases, this function may be
  # useful for calulating a single number from a Halton sequence, or creating
  # a 'leaped' sequence.
  #
  # 'leaped' Halton sequence:
  #
  #   step = 409;
  #   i = 1;
  #   while i < 10 * step
  #     puts Halton.number(17, i)
  #     i += step
  #   end
  #
  # Beware that indexing #each is effectively 0-based, whereas the
  # `index` argument for [`number`] is 1-based.
  #
  #   Halton.each(2).take(10)[2]   #=> 0.75
  #   Halton.number(2, 3)          #=> 0.75

  # :call-seq:
  # Halton.each(base) {|n| ... }
  # Halton.each(base_x, base_y) {|x, y| ... }
  # Halton.each(base_x, base_y, base_z) {|x, y, z| ... }
  # Halton.each(*bases) {|*n| ... }
  # Halton.each(*bases) -> Enumerator
  #
  # Implements the fast generation of Halton sequences.
  # The method of generation is adapted from "Fast, portable, and reliable
  # algorithm for the calculation of Halton numbers" by Miroslav Kolář and
  # Seamus F. O'Shea.
  #
  # The numbers yielded will be in the range > 0 and < 1.
  #
  def self.each(base, *bases, &block)
    case bases.length
    when 0
      each_one(base, &block)
    when 1
      each_pair(base, bases.first, &block)
    when 2
      each_triple(base, bases.first, bases.last, &block)
    else
      each_many(*bases.unshift(base), &block)
    end
  end

  # Halton::Sequence implements the fast generation of Halton sequences.
  # The method of generation is adapted from "Fast, portable, and reliable
  # algorithm for the calculation of Halton numbers" by Miroslav Kolář and
  # Seamus F. O'Shea.
  #
  # This class is implemented as a stateful iterator, a pattern not common in
  # Ruby. The Halton::each method provides a more friendly interface to this
  # class.
  #
  class Sequence

    ##
    # :singleton-method: new
    # :call-seq: Sequence.new(base) -> sequence
    #
    # Create a new Halton::Sequence.

    ##
    # :method: next
    # :call-seq: sequence.next -> int
    #
    # Get the next number in the sequence. The numbers will be in the range > 0
    # and < 1.
    #
    # Will raise StopIteration when the sequence has ended.

    ##
    # :method: skip
    # :call-seq: sequence.skip(n) -> nil
    #
    # Can be used to efficiently skip large sections of the sequence. For small
    # values of +n+ simply advances the sequence +n+ times.

    ##
    # :method: remaining
    # :call-seq: sequence.remaining -> int or nil
    #
    # Returns the count of the remaining numbers in the sequence. May return
    # +nil+ if the count is larger than the host platform's native unsigned
    # integer type.

  end

end
