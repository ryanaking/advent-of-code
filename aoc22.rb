module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day22
      attr_accessor :bricks

      class Brick
        attr_accessor :x, :y, :z, :x2, :y2, :z2

        def initialize(line_parts)
          @x, @y, @z = line_parts[0].split(',').map(&:to_i)
          @x2, @y2, @z2 = line_parts[1].split(',').map(&:to_i)
        end

        def settle!(bricks)
          @z, @z2 = new_position_after_falling(bricks - [self])
        end

        def x_spots_occupied
          Array(([@x, @x2].min)..([@x, @x2].max))
        end

        def y_spots_occupied
          Array(([@y, @y2].min)..([@y, @y2].max))
        end

        def would_collide_in_x_y?(other_brick)
           (x_spots_occupied & other_brick.x_spots_occupied).any? && (y_spots_occupied & other_brick.y_spots_occupied).any?
        end

        def collides?(bricks, z)
          # select all bricks at this 'Z altitude' and see if we would collide with it in X,Y space
          bricks.select { |brick| (brick.z >= z && brick.z2 <= z) || (brick.z2 >= z && brick.z <= z) }.each do |brick|
            if would_collide_in_x_y?(brick)
              return true
            end
          end
          false
        end

        def new_position_after_falling(bricks)
          # fall along "z" until we run into any other brick
          bottom_z = [@z, @z2].min
          z_length = (@z - @z2).abs

          new_z = @z
          new_z2 = @z2

          bottom_z.downto(1).each do |z|
            break if collides?(bricks, z)
            new_z = z
            new_z2 = z + z_length
          end

          [new_z, new_z2]
        end

        def number_of_bricks_impacted_by_disintegration(bricks)
          num_impacted_bricks = 0

          # do a deep copy since we will be modifying other bricks to see where they would fall when this one is disintegrated
          other_bricks = Marshal.load( Marshal.dump(bricks - [self]) )

          # look at each other brick in increasing z order
          other_bricks.sort_by { |brick| [brick.z, brick.z2].min }.each do |other_brick|
            # dont need to look at any bricks unless they are "above" this brick
            if other_brick.z >= [self.z, self.z2].min && other_brick.z2 >= [self.z, self.z2].min
              # see what the new position of the other brick would be if we disintegrated this brick
              new_z, new_z2 = other_brick.new_position_after_falling(other_bricks - [other_brick])
              if [new_z, new_z2] != [other_brick.z, other_brick.z2]
                # update that new position to have it settle into its new place, possibly causing a chain reaction above it
                other_brick.z = new_z
                other_brick.z2 = new_z2
                num_impacted_bricks += 1
              end
            end
          end

          num_impacted_bricks
        end
      end

      def initialize(filename)
        @bricks = []

        File.open(filename).each_with_index do |line, i|
          b = Brick.new(line.strip.split('~'))
          @bricks << b
        end
      end

      def settle_bricks!
        # settle in "z" order
        @bricks.sort_by { |brick| [brick.z, brick.z2].min }.each do |brick|
          brick.settle!(@bricks)
        end
      end

      def part_1
        settle_bricks!
        disintegratable = 0

        @bricks.each do |brick|
          disintegratable += 1 if brick.number_of_bricks_impacted_by_disintegration(@bricks) == 0
        end

        disintegratable
      end

      def part_2
        settle_bricks!
        total_bricks_impacted = 0

        @bricks.each do |brick|
          total_bricks_impacted += brick.number_of_bricks_impacted_by_disintegration(@bricks)
        end

        total_bricks_impacted
      end
    end
  end
end

a = AdventOfCode::Year2023::Day22.new('aoc22.txt')
puts a.part_1
puts a.part_2
