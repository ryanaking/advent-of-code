module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day17
      attr_accessor :heat_map, :min_heat_loss

      MAX_BLOCKS = 3
      MAX_HEAT_LOSS = 2_000_000

      def initialize(filename)
        @heat_map = []
        @min_heat_loss = MAX_HEAT_LOSS
        File.open(filename).each_with_index do |line, y|
          line.chomp.split('').each_with_index do |char, x|
            @heat_map[x] ||= []
            @heat_map[x] << char.to_i
          end
        end
      end

      def opposite_direction(direction)
        case direction
        when :north
          :south
        when :east
          :west
        when :south
          :north
        when :west
          :east
        else
          raise "Unknown direction: #{direction}"
        end
      end

      def valid_directions(x, y, current_direction, current_steps)
        directions = []
        directions += [:north] if  y > 0
        directions += [:east] if  x < @heat_map.length - 1
        directions += [:south] if  y < @heat_map.length - 1
        directions += [:west] if  x > 0
        directions -= [opposite_direction(current_direction)]
        directions -= [current_direction] if current_steps == MAX_BLOCKS
        directions
      end

      def new_direction(x,y,direction)
        case direction
        when :east
          [x + 1, y]
        when :north
          [x, y - 1]
        when :south
          [x, y + 1]
        when :west
          [x - 1, y]
        else
          raise "Unknown direction: #{direction}"
        end
      end

      def navigate(x, y, current_direction, current_steps, total_heat_loss, path_so_far)
        return 0 if x < 0 || y < 0 || x >= @heat_map.length || y >= @heat_map[0].length

        puts "navigate(#{x}, #{y}, #{current_direction}, #{current_steps}, #{total_heat_loss}"

        total_heat_loss += @heat_map[x][y]

        # found the exit
        if x == @heat_map.length - 1 && y == @heat_map[0].length - 1
          @min_heat_loss = [@min_heat_loss, total_heat_loss].min
          puts "found exit with @min_heat_loss = #{@min_heat_loss} and total_heat_loss = #{total_heat_loss}"
          return total_heat_loss
        end

        directions = valid_directions(x,y,current_direction, current_steps)

        possible_heat_losses = [0]

        #puts "exploring directions for #{x}, #{y}: #{directions}, #{current_steps}, #{total_heat_loss}, visited[9][2] = #{visited[9][2]}}"

        directions.each do |direction|
          current_steps = direction != current_direction ? 0 : current_steps + 1

          new_x, new_y = new_direction(x,y,direction)

          if !path_so_far.include?([x, y])
            possible_heat_losses << navigate(new_x, new_y, direction, current_steps, total_heat_loss, path_so_far.clone.push([x,y]))
          end
        end

        #puts "possible_heat_losses for #{x}, #{y}: #{possible_heat_losses}"
        total_heat_loss + possible_heat_losses.min
      end


      def part_1
        #navigate(0, 0, :east, 0, 0, [])
        @min_heat_loss
      end

      def part_2

      end
    end
  end
end

a = AdventOfCode::Year2023::Day17.new('sample17.txt')
puts a.part_1
#puts a.part_2
