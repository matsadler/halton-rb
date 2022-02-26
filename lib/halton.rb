# frozen_string_literal: true

require_relative "halton/halton"

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
  def self.each(base, *bases)
    return to_enum(__method__, base, *bases) unless block_given?

    if bases.empty?
      seq = Sequence.new(base)
      loop {yield seq.next}
      return nil
    end

    if bases.length == 1
      x = Sequence.new(base)
      y = Sequence.new(bases.first)
      loop {yield x.next, y.next}
      return nil
    end

    if bases.length == 2
      x = Sequence.new(base)
      y = Sequence.new(bases.first)
      z = Sequence.new(bases.last)
      loop {yield x.next, y.next, z.next}
      return nil
    end

    seqs = bases.unshift(base).map {|b| Sequence.new(b)}
    loop {yield(*seqs.map(&:next))}
    nil
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
