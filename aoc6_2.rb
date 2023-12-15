
module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day06Part2

      def initialize(filename)
        parse_input(filename)
      end

      def parse_input(filename)
        lines = File.readlines(filename, chomp: true)
        @time = lines[0].split(':')[1].gsub(/\s+/, '').to_i
        @distance = lines[1].split(':')[1].gsub(/\s+/, '').to_i
      end

      # figure out the number of possible ways to win this particular race (brute force, try every possible way)
      def number_of_record_beating_ways_for_race(time, distance)
        num_ways_to_beat = 0

        # don't really need to check 0 or holding it the entire time...
        for hold_time in (1..time-2) do
          # check if distance = travel time * speed is greater than the record
          num_ways_to_beat += 1 if ((time - hold_time) * hold_time) > distance
        end
        num_ways_to_beat
      end

      def record_beating_ways
        number_of_record_beating_ways_for_race(@time, @distance)
      end
    end
  end
end

a = AdventOfCode::Year2023::Day06Part2.new('aoc6.txt')
a.record_beating_ways
