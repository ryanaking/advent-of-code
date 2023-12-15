
module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day06

      def initialize(filename)
        @record_beating_ways = []
        parse_input(filename)
      end

      def parse_input(filename)
        lines = File.readlines(filename, chomp: true)
        @times = lines[0].split(':')[1].split(' ').map(&:to_i)
        @distances = lines[1].split(':')[1].split(' ').map(&:to_i)
        @num_races = @times.size
      end

      # figure out long we'll travel if we hold the button for a certain amount of time
      def find_distance_for_hold_time(hold_time, total_time)
        travel_time = total_time - hold_time
        speed = hold_time
        distance = travel_time * speed
      end

      # figure out the number of possible ways to win this particular race
      def number_of_record_beating_ways_for_race(time, distance)
        num_ways = 0

        for i in (0..time-1) do
          if distance < find_distance_for_hold_time(i, time)
            num_ways += 1
          end
        end
        num_ways
      end

      def build_all_record_beating_ways
        for i in (0..@num_races-1) do
          @record_beating_ways << number_of_record_beating_ways_for_race(@times[i], @distances[i])
        end
      end

      def product_of_record_beating_ways
        build_all_record_beating_ways
        @record_beating_ways.inject(:*)
      end
    end
  end
end

a = AdventOfCode::Year2023::Day06.new('aoc6.txt')
a.product_of_record_beating_ways
