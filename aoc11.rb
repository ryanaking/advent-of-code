module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day11
      attr_accessor :space, :galaxy_count, :galaxy_locations

      def initialize(filename)
        @space = []
        @galaxy_count = 0
        File.open(filename).each_with_index do |line, y|
          line.strip.each_char.each_with_index do |char, x|
            @space[x] ||= []
            if char == '#'
              @galaxy_count += 1
              @space[x][y] = @galaxy_count
            else
              @space[x][y] = :empty
            end
          end
        end
      end

      def compute_galaxy_locations
        @galaxy_locations = {}
        @space.each_with_index do |row, i|
          row.each_index do |j|
            if @space[i][j] != :empty
              @galaxy_locations[@space[i][j]] = [i,j]
            end
          end
        end
      end

      def cosmic_expansion(expansion_factor)
        empty_rows = []
        empty_columns = []

        # first, see if there are any rows of only empty
        space[0].each_index do |y|
          row = @space.collect { |row| row[y] }
          if row.all? { |element| element == :empty }
            empty_rows << y
          end
        end

        # then, see if there are any empty columns
        @space.each_with_index do |column, i|
          if column.all? { |element| element == :empty }
            empty_columns << i
          end
        end

        # for each empty row, advance all galaxy_locations' row number after that row by the expansion factor - 1
        empty_rows.sort.reverse.each do |row_num|
          @galaxy_locations.each_key do |i|
            if @galaxy_locations[i][1] > row_num
              @galaxy_locations[i] = [@galaxy_locations[i][0], @galaxy_locations[i][1] + expansion_factor - 1]
            end
          end
        end

        # for each empty column, advance all galaxy_locations' column number after that column by the expansion factor - 1
        empty_columns.sort.reverse.each do |col_num|
          @galaxy_locations.each_key do |i|
            if @galaxy_locations[i][0] > col_num
              @galaxy_locations[i] = [@galaxy_locations[i][0] + expansion_factor - 1, @galaxy_locations[i][1]]
            end
          end
        end

        puts "galaxy_locations = #{@galaxy_locations}"
      end

      def shortest_path(from,to)
        (@galaxy_locations[from][0] - @galaxy_locations[to][0]).abs + (@galaxy_locations[from][1] - @galaxy_locations[to][1]).abs
      end

      def shortest_paths
        paths = []
        for galaxy_number in 1..@galaxy_count do
          other_galaxies = *(galaxy_number..@galaxy_count)
          other_galaxies.delete(galaxy_number)
          other_galaxies.each do |other_galaxy_number|
            paths << shortest_path(galaxy_number, other_galaxy_number)
          end
        end
        paths
      end

      def compute(expansion_factor)
        compute_galaxy_locations
        cosmic_expansion(expansion_factor)
        shortest_paths.reduce(:+)
      end

      def part_1
        compute(2)
      end

      def part_2
        compute(1_000_000)
      end
    end
  end
end

a = AdventOfCode::Year2023::Day11.new('aoc11.txt')
a.part_1
a.part_2
