module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day21
      attr_accessor :map, :starting_positions, :step_map

      def initialize(filename)
        @map = []
        @starting_positions = {}

        File.open(filename).each do |line|
          @map << line.strip.split('')
        end

        @map.each_with_index do |row, y|
          row.each_with_index do |col, x|
            if col == 'S'
              @starting_positions[[y, x]] = true
            end
          end
        end

        @step_map = @map.map(&:clone)
      end

      def adjacent_tiles(pos)
        adjacent = []
        adjacent << [pos[0] - 1, pos[1]] if pos[0] > 0
        adjacent << [pos[0] + 1, pos[1]] if pos[0] < @map.length - 1
        adjacent << [pos[0], pos[1] - 1] if pos[1] > 0
        adjacent << [pos[0], pos[1] + 1] if pos[1] < @map[0].length - 1
        adjacent
      end

      def take_step!
        new_starting_positions = {}
        @starting_positions.each_key do |pos|
          # check all adjacent tiles for 'O', '.', or 'S'
          adjacent_tiles(pos).each do |adj|
            if ['O', '.', 'S'].include?(@map[adj[0]][adj[1]])
              @step_map[adj[0]][adj[1]] = 'O'
              new_starting_positions[adj] = true
            end
          end
        end
        @starting_positions = new_starting_positions
        nil
      end

      def part_1
        64.times do |i|
          @step_map = @map.map(&:clone)
          take_step!
          # @step_map.each do |m|
          #   puts m.join('')
          # end
          #puts "step #{i+1} tiles_reached: #{@starting_positions.size}"
        end
        @starting_positions.size
      end

      def part_2
        26501365.times do |i|
          take_step!
        end
        @starting_positions.size
      end
    end
  end
end

a = AdventOfCode::Year2023::Day21.new('aoc21.txt')
#puts a.part_1
puts a.part_2
