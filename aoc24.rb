module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day24
      attr_accessor :hailstones, :test_area_start, :test_area_end

      class HailStone
        attr_accessor :position_x, :position_y, :position_z, :velocity_x, :velocity_y, :velocity_z

        def initialize(line)
          parts = line.split('@')
          @position_x = parts[0].split(', ')[0].to_f
          @position_y = parts[0].split(', ')[1].to_f
          @position_z = parts[0].split(', ')[2].to_f
          @velocity_x = parts[1].split(', ')[0].to_f
          @velocity_y = parts[1].split(', ')[1].to_f
          @velocity_z = parts[1].split(', ')[2].to_f
        end

        def next_x_position
          @position_x + @velocity_x
        end

        def next_y_position
          @position_y + @velocity_y
        end

        def next_z_position
          @position_z + @velocity_z
        end

        # m = (y2 - y1) / (x2 - x1)
        def slope_2d
          (next_y_position - @position_y) / (next_x_position - @position_x)
        end

        # b = y - mx
        def intercept_2d
          @position_y - slope_2d * @position_x
        end

        def intersection_point_2d(other_hailstone)
          # y1 = m1x + b1
          # y2 = m2x + b2
          # x = (b2 - b1)/(m1 - m2)
          # y = (m1 b2 - m2 b1)/(m1 - m2)
          x = (other_hailstone.intercept_2d - intercept_2d) / (slope_2d - other_hailstone.slope_2d)
          y = (slope_2d * other_hailstone.intercept_2d - other_hailstone.slope_2d * intercept_2d) / (slope_2d - other_hailstone.slope_2d)
          [x,y]
        end

        def point_in_past?(x,y,z=0)
          (@velocity_x < 0 && x > @position_x) ||
            (@velocity_y < 0 && y > @position_y) ||
            (@velocity_x > 0 && x < @position_x) ||
            (@velocity_y > 0 && y < @position_y) ||
            (@velocity_z < 0 && z != 0 && z > @position_z) ||
            (@velocity_z > 0 && z != 0 && z < @position_z)
        end

        def intersects_in_past?(other_hailstone)
          x, y  = intersection_point_2d(other_hailstone)
          point_in_past?(x,y) || other_hailstone.point_in_past?(x,y)
        end
      end

      def initialize(filename)
        @hailstones = []
        File.open(filename).each_with_index do |line, i|
          @hailstones << HailStone.new(line.chomp)
        end
      end

      def inside_test_area?(intersection)
        intersection[0] >= @test_area_start &&
          intersection[0] <= @test_area_end &&
          intersection[1] >= @test_area_start &&
          intersection[1] <= @test_area_end
      end

      def part_1
        future_paths_cross = 0
        @test_area_start = 7
        @test_area_end = 27
        # @test_area_start = 200000000000000
        # @test_area_end = 400000000000000

        @hailstones.each_with_index do |h, i|
          for j in (i+1..@hailstones.length - 1) do
            intersection = h.intersection_point_2d(@hailstones[j])
            puts "Hailstone #{i} intersects with #{j} at #{intersection} #{h.intersects_in_past?(@hailstones[j]) ? 'in the past' : 'in the future'} #{inside_test_area?(intersection) ? 'in the test area' : 'not in the test area'}"

            # figure out if they intersect in the test area, and in the future
            if inside_test_area?(intersection) && !h.intersects_in_past?(@hailstones[j])
              future_paths_cross += 1
            end
          end
        end
        future_paths_cross
      end

      def part_2

      end
    end
  end
end

a = AdventOfCode::Year2023::Day24.new('sample24.txt')
puts a.part_1
#puts a.part_2
