module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day14
      attr_accessor :patterns

      DISH_MAP = {
        'O' => :rock,
        '.' => :empty,
        '#' => :cube
      }

      def initialize(filename)
        @rows = []
        File.open(filename).each do |line|
          @rows << line.strip.split('').map { |c| DISH_MAP[c] }
        end
      end

      def tilt!
        @rows.each_with_index do |row, i|
          if i != 0
            row.each_with_index do |d, j|
              if d == :rock
                for k in (i-1).downto(0)
                  if @rows[k][j] == :empty
                    @rows[k][j] = :rock
                    @rows[k+1][j] = :empty
                  else
                    break
                  end
                end
              end
            end
          end
        end
      end

      def total_load
        total = 0
        @rows.each_with_index do |row, i|
          row.each do |d|
            if d == :rock
              total += @rows.length - i
            end
          end
        end
        total
      end

      def part_1
        tilt!
        total_load
      end

      def part_2

      end
    end
  end
end

a = AdventOfCode::Year2023::Day14.new('aoc14.txt')
puts a.part_1
#puts a.part_2
