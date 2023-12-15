require_relative 'utils'

module AdventOfCode
  class Day
    DEFAULT_PARSER = lambda { |line| line }

    class << self
      include AdventOfCode::Utils

      def input_blob=(input)
        @input_blob = input
      end

      def input_blob
        @input_blob ||=  File.read(input_file_path)
      end

      def input_lines=(input)
        @input_lines = input
      end

      def input_lines
        @input_lines ||= File.readlines(input_file_path).map(&:chomp)
      end

      def parsed_input
        lambda = self::INPUT_PARSER || self::DEFAULT_PARSER
        @parsed_input = input_lines.map { |a| lambda.call(a) }
      end

      def input_file_path
        input_filename(self::DAY, self::YEAR)
      end

      def chunked_input(lines)
        parsed_input.each_slice(lines).to_a
      end

      def separated_input(separator = "", include_in_previous: false)
        current = []
        parsed_input.each_with_object([]) do |line, all|
          if line == separator
            current << line if include_in_previous
            all << current
            current = []
          else
            current << line
          end
        end
      end
    end
  end
end

