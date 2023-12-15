module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day09
      attr_accessor :sequences

      def initialize(filename)
        @sequences = []
        File.open(filename).each do |line|
          @sequences << line.split(' ').map(&:to_i)
        end
      end

      def compute_deltas(sequence)
        current_sequence = sequence
        deltas = [current_sequence]
        begin
          current_delta = []
          current_sequence.each_index do |i|
            current_delta << (current_sequence[i+1] - current_sequence[i]) if i != (current_sequence.length - 1)
          end
          deltas << current_delta
          current_sequence = current_delta
        end while current_delta.uniq.size != 1
        deltas
      end

      def extrapolated_next_value(sequence)
        deltas = compute_deltas(sequence)
        i = deltas.length - 2
        while i >= 0 do
          deltas[i] << deltas[i][-1] + deltas[i+1][-1]
          i -= 1
        end
        deltas.first.last
      end

      def extrapolated_next_values
        @sequences.collect do |sequence|
          extrapolated_next_value(sequence)
        end
      end

      def extrapolated_previous_value(sequence)
        deltas = compute_deltas(sequence)
        i = deltas.length - 2
        while i >= 0 do
          deltas[i].unshift(deltas[i][0] - deltas[i+1][0])
          i -= 1
        end
        deltas.first.first
      end

      def extrapolated_previous_values
        @sequences.collect do |sequence|
          extrapolated_previous_value(sequence)
        end
      end

      def part1
        extrapolated_next_values.reduce(:+)
      end

      def part2
        extrapolated_previous_values.reduce(:+)
      end
    end
  end
end

a = AdventOfCode::Year2023::Day09.new('aoc9.txt')
a.part1