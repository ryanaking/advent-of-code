module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day12
      attr_accessor :rows

      class Row
        attr_accessor :springs, :damaged_groups

        SPRING_MAP = {
          '.' => :operational,
          '#' => :damaged,
          '?' => :unknown
        }

        def initialize(line)
          line_parts = line.strip.split(' ')
          @springs = line_parts[0].split('').collect { |x| SPRING_MAP[x] }
          @damaged_groups = line_parts[1].split(',').map(&:to_i)
        end

        def num_possible_arrangements(springs)
          #  if this permutation is valid
          unknown_location  = springs.index(:unknown)
          if unknown_location.nil?
            return valid?(springs) ? 1 : 0
          else
            permuted_row = springs.dup
            permuted_row[unknown_location] = :operational
            permuted_row2 = springs.dup
            permuted_row2[unknown_location] = :damaged
            num_possible_arrangements(permuted_row) + num_possible_arrangements(permuted_row2)
          end
        end

        def valid?(springs)
          if springs.count(:damaged) != @damaged_groups.reduce(:+)
            return false
          end

          contiguous_damaged_count = 0
          damaged_group_num = 0

          springs.each_index do |j|
            if springs[j] == :damaged
              contiguous_damaged_count += 1
              if contiguous_damaged_count > @damaged_groups[damaged_group_num]
                return false
              end
            elsif contiguous_damaged_count > 0
              if contiguous_damaged_count != @damaged_groups[damaged_group_num]
                return false
              else
                damaged_group_num += 1
                contiguous_damaged_count = 0
              end
            end
          end

          if damaged_group_num < (@damaged_groups.size - 1)
            puts "#{springs} not valid, only found #{damaged_group_num} groups vs. #{@damaged_groups.size - 1}"
            return false
          end

          return true
        end
      end

      def initialize(filename)
        @rows = []
        File.open(filename).each do |line|
          @rows << Row.new(line)
        end
      end

      def possible_arrangements
        @rows.collect { |row| row.num_possible_arrangements(row.springs) }
      end

      def part_1
        possible_arrangements.reduce(:+)
      end

      def part_2
        possible_arrangements.reduce(:+)
      end
    end
  end
end

a = AdventOfCode::Year2023::Day12.new('sample12.txt')
#a.part_1
a.part_2
