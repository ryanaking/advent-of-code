# seed -> location map
#[79, 50]
#[82, 46]

# then find seed with min location

module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day05Part2

      DESTINATION = 0
      SOURCE = 1
      RANGE = 2

      MAP_LIST = ['seed-to-soil map:',
                  'soil-to-fertilizer map:',
                  'fertilizer-to-water map:',
                  'water-to-light map:',
                  'light-to-temperature map:',
                  'temperature-to-humidity map:',
                  'humidity-to-location map:'
      ]

      attr_accessor :maps, :seeds, :full_maps

      def initialize(filename)
        @maps = {}
        @seeds = []
        @seed_ranges = []
        @seed_location_map = {}
        parse_input(filename)
      end

      def parse_input(filename)
        map_type = nil
        lines = File.readlines(filename, chomp: true)
        lines.each do |line|
          if line.start_with?('seeds:')
            @seeds = line.split(':')[1].split(' ').map(&:to_i)
          elsif line.include?(':')
            map_type = line.strip
          elsif line.strip.length > 0
            @maps[map_type] ||= []
            @maps[map_type] << line.strip.split(' ').map(&:to_i)
          end
        end

        @seed_ranges = @seeds.each_slice(2).to_a
        build_seed_location_maps
      end

      def in_range?(source, source_range, source_destination_map)
        source_destination_map[SOURCE] + source_destination_map[RANGE] >= source &&
          source_destination_map[SOURCE] <= source
      end

      # input: 50, 2, [0, 15, 37]
      # output: [35, 50, 2]
      def find_intersection(source, source_range, source_destination_map)
        if in_range?(source, source_range, source_destination_map)
          [source_destination_map[DESTINATION] + source - source_destination_map[SOURCE], source, [source_range, source_destination_map[RANGE]].min]
        else
          nil
        end
      end

      def build_intersection_map(input_map, map_name)
        intersection_map ||= [input_map[DESTINATION], input_map[DESTINATION], input_map[RANGE]]
        @maps[map_name].each do |map|
          imap = find_intersection(input_map[DESTINATION], input_map[RANGE], map)
          if imap
            intersection_map = imap
          end
        end
        intersection_map
      end

      # build out seed->location maps
      def build_seed_location_maps
        # for each starting seed range
        @seed_ranges.each do |seed_range|
          # map the entire range to a list of seeds->locations
        end
      end

      # part 2
      def lowest_location_number

      end
    end
  end
end

a = AdventOfCode::Year2023::Day05Part2.new('sample5.txt')
a.lowest_location_number

