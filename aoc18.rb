module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day18
      attr_accessor :dig_plan, :lava, :lava_min_x_values, :lava_max_x_values, :filled_in_lava

      #DEBUG_VALUES = *(-250..-230)
      DEBUG_VALUES = []

      DIRECTION_MAP = {
        'L' => [-1, 0],
        'R' => [1, 0],
        'U' => [0, -1],
        'D' => [0, 1]
      }

      COLOR_DIRECTION_MAP = {
        '0' => 'R',
        '1' => 'D',
        '2' => 'L',
        '3' => 'U'
      }

      class Dig
        attr_accessor :direction, :distance, :color
        def initialize(line)
          parsed_line = line.chomp.split(' ')
          @direction = parsed_line[0]
          @distance = parsed_line[1].to_i
          @color = parsed_line[2]
        end
      end

      def initialize(filename)
        @dig_plan = []
        @lava = {}
        File.open(filename).each_with_index do |line, y|
          @dig_plan << Dig.new(line)
        end
        @lava_min_x_values = {}
        @lava_max_x_values = {}
      end

      def decode_color_instructions!
        @dig_plan.each do |dig|
          dig.distance = dig.color[2..-3].hex
          dig.direction = COLOR_DIRECTION_MAP[ dig.color[-2] ]
        end
      end

      def dig_edges!
        # dig all the edges, recording each step along the way, keeping track of the min/max x values for each row
        current_position = [0, 0]
        @dig_plan.each do |dig|
          dig.distance.times do |i|
            current_position[0] += DIRECTION_MAP[dig.direction][0]
            current_position[1] += DIRECTION_MAP[dig.direction][1]
            @lava_min_x_values[ current_position[1] ] = [ @lava_min_x_values[current_position[1] ], current_position[0] ].compact.min
            @lava_max_x_values[ current_position[1] ] = [ @lava_max_x_values[current_position[1] ], current_position[0] ].compact.max
            @lava[current_position.dup] = true
          end
        end
        @filled_in_lava = @lava.dup
      end

      def min_x
        @lava.keys.min_by { |x, y| x }[0]
      end

      def min_y
        @lava.keys.min_by { |x, y| y }[1]
      end

      def max_x
        @lava.keys.max_by { |x, y| x }[0]
      end

      def max_y
        @lava.keys.max_by { |x, y| y }[1]
      end

      def map_terrain(filled_in = false)
        # print a map of the lava grid
        (min_y..max_y).each do |y|
          next unless DEBUG_VALUES.empty? || DEBUG_VALUES.include?(y)
          print y
          (min_x..max_x).each do |x|
            if (filled_in && @filled_in_lava[[x,y]] == true) || @lava[[x, y]] == true
              print '#'
            else
              print '.'
            end
          end
          puts
        end
      end

      def is_edge?(x, y)
        @lava[[x, y]] == true && (@lava[[x-1, y]].nil? || @lava[[x+1, y]].nil?)
      end

      def is_border_wall?(x,y)
        @lava[[x, y]] == true && @lava[[x-1, y]].nil? && @lava[[x+1, y]].nil?
      end

      def fill_in_lava
        # now go through each row, and fill in cells "inside" of the lava grid
        (min_y..max_y).each do |y|
          inside = false

          ((@lava_min_x_values[y])..(@lava_max_x_values[y])).each do |x|
            if is_border_wall?(x,y)
              inside = !inside
            elsif is_edge?(x, y)
              inside = @filled_in_lava[[x+1, y-1]].nil? ? false : true
            elsif inside
              @filled_in_lava[[x, y]] = true
            end
          end
        end
      end

      def part_1
        dig_edges!
        fill_in_lava
        @filled_in_lava.count
      end

      def part_2
        decode_color_instructions!
        #dig_edges!
        #fill_in_lava
        #@filled_in_lava.count
      end
    end
  end
end

a = AdventOfCode::Year2023::Day18.new('aoc18.txt')
puts a.part_1
#puts a.part_2
