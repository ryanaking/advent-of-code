module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day23
      attr_accessor :trails, :end_x_pos, :end_y_pos

      TRAIL_MAP = {
        '.' => :path,
        '#' => :forest,
        '^' => :up_slope,
        'v' => :down_slope,
        '<' => :left_slope,
        '>' => :right_slope,
      }

      TRAIL_MAP2 = {
        '.' => :path,
        '#' => :forest,
        '^' => :path,
        'v' => :path,
        '<' => :path,
        '>' => :path,
      }

      def initialize(filename)
        @trails = []

        File.open(filename).each_with_index do |line, i|
            line.chomp.each_char.with_index do |c, j|
              @trails[j] ||= []
              @trails[j][i] = TRAIL_MAP2[c]
          end
        end

        @end_x_pos = @trails.collect { |trail| trail[-1] }.index(:path)
        @end_y_pos = @trails.length - 1

        puts @trails.inspect
      end

      def valid_next_cells(x, y, path_so_far)
        next_cells = []
        next_cells << [x, y -1] if  y > 0 && path_so_far[[x,y-1]].nil? && @trails[x][y-1] != :forest && [:path, :up_slope].include?(@trails[x][y])
        next_cells << [x+1, y] if  x < @trails.length - 1 && path_so_far[[x+1,y]].nil? && @trails[x+1][y] != :forest && [:path, :right_slope].include?(@trails[x][y])
        next_cells << [x, y+1] if  y < @trails[0].length - 1 && path_so_far[[x,y+1]].nil? && @trails[x][y+1] != :forest && [:path, :down_slope].include?(@trails[x][y])
        next_cells << [x-1,y] if  x > 0 && path_so_far[[x-1,y]].nil? && @trails[x-1][y] != :forest && [:path, :left_slope].include?(@trails[x][y])
        next_cells
      end

      def navigate(start_x_pos, start_y_pos, visited_so_far, steps)
        #puts "navigate(x=#{start_x_pos}, y=#{start_y_pos}), steps=#{steps}"

        # found the exit
        if start_x_pos == @end_x_pos && start_y_pos == @end_y_pos
          #puts "found exit"
          return visited_so_far.size
        end

        visited = Marshal.load( Marshal.dump(visited_so_far) )
        visited[ [start_x_pos, start_y_pos] ] = true

        next_cells = valid_next_cells(start_x_pos,start_y_pos, visited)
        next_cells.each do |cell|
          #puts "navigating to #{cell[0]}, #{cell[1]}"
          steps = [navigate(cell[0], cell[1], visited, steps), steps].max
        end
        #puts "returning steps=#{steps}"
        steps
      end

      def part_1
        start_x_pos = 1
        puts "end_x_pos=#{@end_x_pos}"
        puts "end_y_pos=#{@end_y_pos}"
        steps = navigate(start_x_pos, 0, {}, 0)
        steps
      end

      def part_2
        start_x_pos = 1
        puts "end_x_pos=#{@end_x_pos}"
        puts "end_y_pos=#{@end_y_pos}"
        steps = navigate(start_x_pos, 0, {}, 0)
        steps
      end
    end
  end
end

a = AdventOfCode::Year2023::Day23.new('sample23.txt')
#puts a.part_1
puts a.part_2
