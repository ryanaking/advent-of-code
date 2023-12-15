
module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day05

      SEED = 'seed'
      SOIL = 'soil'
      FERTILIZER = 'fertilizer'
      WATER = 'water'
      LIGHT = 'light'
      TEMPERATURE = 'temperature'
      HUMIDITY = 'humidity'
      LOCATION = 'location'

      attr_accessor :maps, :seeds

      def initialize(filename)
        @maps = {}
        @seeds = []
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
      end

      def map_source_to_destination(source_number, source, destination)
        map_name = source + '-to-' + destination + ' map:'
        destination_number = source_number
        @maps[map_name].each do |map|
          if source_number >= map[1] && source_number < (map[1] + map[2])
            destination_number = map[0] + (source_number - map[1])
          end
        end
        destination_number
      end

      def find_location_number(seed)
        # start with the seed number
        # map to soil number
        soil = map_source_to_destination(seed,  SEED, SOIL)
        # map to fertilizer
        fertilizer = map_source_to_destination(soil, SOIL, FERTILIZER)
        # map to water
        water = map_source_to_destination(fertilizer, FERTILIZER, WATER)
        # map to light
        light = map_source_to_destination(water, WATER, LIGHT)
        # map to temperature
        temperature = map_source_to_destination(light, LIGHT, TEMPERATURE)
        # map to humidity
        humidity = map_source_to_destination(temperature, TEMPERATURE, HUMIDITY)
        # map to location
        map_source_to_destination(humidity, HUMIDITY, LOCATION)
      end

      # part 1
      def lowest_location_number
        @seeds.collect { |s| find_location_number(s) }.min
      end
    end
  end
end

a = AdventOfCode::Year2023::Day05.new('aoc5.txt')
a.lowest_location_number
