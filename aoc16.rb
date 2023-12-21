module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day16
      attr_accessor :grid, :energized_tiles

      GRID_MAP = {
        '.' => :space,
        '/' => :right_mirror,
        '\\' => :left_mirror,
        '|' => :vertical_splitter,
        '-' => :horizontal_splitter,
      }

      def initialize(filename)
        @grid = []
        File.open(filename).each do |line|
          @grid << line.chomp.chars.map { |c| GRID_MAP[c] }
        end
        @energized_tiles = {}
      end

      class Move
        attr_accessor :position, :direction

        def initialize(position, direction)
          @position = position
          @direction = direction
        end

        def out_of_bounds?(width, length)
          @position[0] < 0 || @position[0] >= width || @position[1] < 0 || @position[1] >= length
        end
      end

      def next_position(direction, starting_position)
        case
        when direction == :right
          [starting_position[0], starting_position[1] + 1]
        when direction == :left
          [starting_position[0], starting_position[1] - 1]
        when direction == :up
          [starting_position[0] - 1, starting_position[1]]
        when direction == :down
          [starting_position[0] + 1, starting_position[1]]
        else
          raise "Unknown direction #{direction}"
        end
      end

      def next_directions(current_direction, tile)
        directions = []
        case tile
        when :right_mirror # /
          case current_direction
          when :right
            directions << :up
          when :left
            directions << :down
          when :up
            directions << :right
          when :down
            directions << :left
          else
            raise "Unknown direction #{current_direction}"
          end
        when :left_mirror # \
          case current_direction
          when :right
            directions << :down
          when :left
            directions << :up
          when :up
            directions << :left
          when :down
            directions << :right
          else
            raise "Unknown direction #{current_direction}"
          end
        when :horizontal_splitter # -
          case current_direction
          when :right, :left
            directions << current_direction
          when :up, :down
            directions << :left
            directions << :right
          else
            raise "Unknown direction #{current_direction}"
          end
        when :vertical_splitter # |
          case current_direction
          when  :up, :down
            directions << current_direction
          when :right, :left
            directions << :up
            directions << :down
          else
            raise "Unknown direction #{current_direction}"
          end
        else
          raise "Unknown tile type #{tile}"
        end
        directions
      end

      def next_moves(current_direction, starting_position)
        tile = @grid[starting_position[0]][starting_position[1]]
        moves = []
        case tile
        when :space
          moves << Move.new(next_position(current_direction, starting_position), current_direction)
        when :right_mirror, :left_mirror
          new_direction = next_directions(current_direction, tile).first
          moves << Move.new(next_position(new_direction, starting_position), new_direction)
        when :vertical_splitter, :horizontal_splitter
          new_directions = next_directions(current_direction, tile)
          new_directions.each do |new_direction|
            moves << Move.new(next_position(new_direction, starting_position), new_direction)
          end
        else
          raise "Unknown tile type #{tile}"
        end
        moves
      end

      def energize!(starting_position, direction)
        #puts "energize!(#{starting_position}, #{@grid[starting_position[0]][starting_position[1]]}, #{direction})"
        #puts "energized_tiles size = #{@energized_tiles.size}"

        # energize current tile
        @energized_tiles[starting_position] ||= Array.new
        if @energized_tiles[starting_position].include?(direction)
          #puts "loop detected"
          return
        end

        @energized_tiles[starting_position] << direction

        # based on current tile, figure out where to go next
        next_moves(direction, starting_position).each do |move|
          unless move.out_of_bounds?(@grid[0].size, @grid.size)
            energize!(move.position, move.direction)
          end
        end
      end

      def part_1
        energize!([0,0], :right)
        @energized_tiles.size
      end

      def part_2
        max_energized_tiles = 0
        for i in 0..@grid.size - 1 do
          energize!([i, 0], :right)
          max_energized_tiles = [@energized_tiles.size, max_energized_tiles].max
          @energized_tiles = {}
        end

        for i in 0..@grid.size - 1 do
          energize!([i, @grid[0].size - 1], :left)
          max_energized_tiles = [@energized_tiles.size, max_energized_tiles].max
          @energized_tiles = {}
        end

        for i in 0..@grid[0].size - 1 do
          energize!([0, i], :down)
          max_energized_tiles = [@energized_tiles.size, max_energized_tiles].max
          @energized_tiles = {}
        end

        for i in 0..@grid[0].size - 1 do
          energize!([@grid.size - 1, i], :up)
          max_energized_tiles = [@energized_tiles.size, max_energized_tiles].max
          @energized_tiles = {}
        end
        max_energized_tiles
      end
    end
  end
end

a = AdventOfCode::Year2023::Day16.new('aoc16.txt')
#puts a.part_1
puts a.part_2
