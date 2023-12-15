module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day10Ryan
      attr_accessor :grid, :starting_x, :starting_y, :working_grid

      SHAPE_MAP = {
        '|' => :north_south,
        '-' => :east_west,
        'L' => :north_east,
        'J' => :north_west,
        '7' => :south_west,
        'F' => :south_east,
        '.' => :ground,
        'S' => :start
      }

      VALID_DIRECTIONS = [:north_south, :east_west, :north_east, :north_west, :south_east, :south_west]

      def initialize(filename)
        @grid = []
        File.open(filename).each_with_index do |line, y|
          line.strip.each_char.each_with_index do |char, x|
            @grid[x] ||= []
            @grid[x][y] = SHAPE_MAP[char]
            @starting_x = x if @grid[x][y] == :start
            @starting_y = y if @grid[x][y] == :start
          end
        end
        puts "@grid = #{@grid}"
      end

      def valid_routes(x,y,source_direction)
        routes = []
        # try north
        routes << [x, y-1, :north] if source_direction != :south && y > 0 && [:north_south, :south_east, :south_west, :start].include?(@working_grid[x][y-1])
        # try south
        routes << [x, y+1, :south] if source_direction != :north && y < @working_grid.length - 1 && [:north_south, :north_east, :north_west, :start].include?(@working_grid[x][y+1])
        # try west
        routes << [x-1, y, :west] if source_direction != :east && x > 0 && [:east_west, :north_east, :south_east, :start].include?(@working_grid[x-1][y])
        # try east
        routes << [x+1, y, :east] if source_direction != :west && x < @working_grid.length - 1 && [:east_west, :north_west, :south_west, :start].include?(@working_grid[x+1][y])
        routes
      end

      def find_loop(x, y, source_direction, loop_size)
        if x == @starting_x && y == @starting_y && source_direction != nil
          puts "found loop back to start, returning #{loop_size}"
          return loop_size
        end
        puts "valid_routes for #{x}, #{y}, #{source_direction} = #{valid_routes(x,y,source_direction)}"
        valid_routes(x,y,source_direction).each do |route|
          puts "recursing valid route #{route} with loop_size #{loop_size+1}"
          @working_grid[x][y] = loop_size
          loop_size = find_loop(route[0], route[1], route[2], loop_size + 1)
        end
        puts "end of recursion loop_size = #{loop_size}"
        loop_size
      end

      def duplicate_grid
        @working_grid = []
        @grid.each do |item|
          @working_grid << item.dup
        end
      end

      def part1
        max_loop_size = 0
        duplicate_grid

        # try all possible paths from starting position until we end up back where we started
        valid_routes(@starting_x, @starting_y, nil).each do |route|
          puts "starting down route #{route}"
          duplicate_grid
          loop_size = find_loop(route[0], route[1], route[2], 1)
          max_loop_size = [loop_size, loop_size].max
          puts "working_grid = #{@working_grid}"
        end
        (max_loop_size / 2).to_i
      end

      def part2
      end
    end
  end
end

module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day10
      DAY = 10
      YEAR = 2023
      INPUT_PARSER = lambda { |line| line.split("") }

      ADJACENCY_MAP = {
        "|" => %i[u d],
        "-" => %i[l r],
        "F" => %i[d r],
        "7" => %i[d l],
        "J" => %i[u l],
        "L" => %i[r u],
        "S" => %i[],
        "." => [],
      }.freeze

      OPPOSITES = { u: :d, r: :l }.tap { |h| h.merge!(h.invert) }.freeze

      class Tree
        attr_accessor :root, :nodes

        def initialize(input)
          @root = nil
          @nodes = {}
          input.each_with_index do |row, i|
            row.each_with_index do |val, j|
              node = Node.new(i, j, val)
              node.set_adjacencies!(input)
              @root = node if val == "S"
              @nodes[[i, j]] = node
            end
          end
        end

        def bfs
          to_search = [root]
          distances = {root => 0}

          until to_search.empty?
            node = to_search.shift
            current_distance = distances[node]
            node.adjacencies.each do |k, (i, j)|
              adjacent = @nodes[[i, j]]
              if !node.visited && !adjacent.visited
                to_search << @nodes[[i, j]]
                distances[@nodes[[i, j]]] = current_distance + 1
              end
            end
            node.visited = true
          end

          distances.values.max
        end
      end

      class Node
        attr_accessor :i, :j, :val, :adjacencies, :visited

        def initialize(i, j, val)
          @i = i
          @j = j
          @val = val
          @adjacencies = []
          @visited = false
        end

        def all_adjacencies(i, j, input)
          { u: [i - 1, j], d: [i + 1, j], l: [i, j - 1], r: [i, j + 1] }.select do |k, (i, j)|
            (0...input.length).include?(i) && (0...input[i].length).include?(j)
          end
        end

        def set_adjacencies!(input)
          if val != "S"
            attempted_ajacencies = ADJACENCY_MAP[val]
            @adjacencies = all_adjacencies(i, j, input).select do |k, _|
              attempted_ajacencies.include?(k)
            end
          else
            dirs = []
            @adjacencies = all_adjacencies(i, j, input).select do |k, (i, j)|
              adjacent = ADJACENCY_MAP[input[i][j]]
              dirs << k if adjacent&.include?(OPPOSITES[k])
            end

            # substitute out the S for its practical value
            @val = ADJACENCY_MAP.map { |k, values| k if values.sort == dirs.sort }.compact.first
          end
        end
      end

      class << self
        def parsed_input
          input_lines ||= File.readlines('aoc10.txt').map(&:chomp)
          input_lines.map { |a| a.split("") }
        end

        def run_a
          tree = Tree.new(parsed_input)
          tree.bfs
        end

        def run_b
          tree = Tree.new(parsed_input)
          tree.bfs

          counter = 0
          parsed_input.each_with_index.map do |row, i|
            u, d = 0, 0
            (0...row.length).map do |j|
              node = tree.nodes[[i, j]]
              if node.visited
                ADJACENCY_MAP[node.val].include?(:u) && u += 1
                ADJACENCY_MAP[node.val].include?(:d) && d += 1
              else
                counter += 1 if u.odd? && d.odd?
              end
            end
          end

          counter
        end

      end
    end
  end
end


AdventOfCode::Year2023::Day10.run_b
