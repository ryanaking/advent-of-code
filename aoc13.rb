module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day13
      attr_accessor :patterns

      class Pattern
        attr_accessor :rows, :columns, :mirrored_row_number, :mirrored_column_number, :pattern_number

        def initialize
          @rows = []
          @columns = []
          @pattern_number = 0
          @mirrored_row_number = 0
          @mirrored_column_nunber = 0
        end

        def is_mirror?(dimension, location, name)
          mirror_size = [location, dimension.length - location - 1].min
          for i in 1..(mirror_size + 1) do
            first = location - i
            second = location + i - 1
            if first >= 0 && second <= dimension.length && dimension[first] != dimension[second]
              return false
            end
          end
          puts "found #{name} mirror at #{location} of pattern #{@pattern_number}"
          true
        end

        def find_dimension_mirrors(dimension, name, existing_mirror_number)
          # for each possible mirror
          possible_mirror_locations = 1..(dimension.length - 1)

          possible_mirror_locations.each do |possible_mirror_location|
            if possible_mirror_location != existing_mirror_number
              # check if its a mirror
              if is_mirror?(dimension, possible_mirror_location, name)
                return possible_mirror_location
              end
            end
          end
          0
        end

        def flip(char)
          char == '#' ? '.' : '#'
        end

        def find_mirrors
          @mirrored_row_number = find_dimension_mirrors(@rows, 'row', 0)
          @mirrored_column_number = find_dimension_mirrors(@columns, 'column', 0)
          raise 'missing mirror' if @mirrored_row_number == 0 && @mirrored_column_number == 0
        end

        def find_dimension_smudge(dimension, existing_mirror_number, name)
          new_mirror_number = 0
          # try every position as a potential smudge and see if fixing that smudge finds a NEW mirror
          dimension.each_index do |i|
            dimension[i].split('').each_with_index do |char, j|
              dimension[i][j] = flip(char)
              #puts "smudge #{i},#{j} of #{name}"
              new_mirror_number = find_dimension_mirrors(dimension, name, existing_mirror_number)
              dimension[i][j] = flip(dimension[i][j])
              if new_mirror_number > 0 && new_mirror_number != existing_mirror_number
                return new_mirror_number
              end
            end
          end
          0
        end

        def find_smudge
          @mirrored_row_number = find_dimension_smudge(@rows, @mirrored_row_number, 'row')
          if @mirrored_row_number.zero?
            @mirrored_column_number = find_dimension_smudge(@columns, @mirrored_column_number, 'column')
          else
            @mirrored_column_number = 0
          end
          raise 'missing smudged mirror' if @mirrored_row_number == 0 && @mirrored_column_number == 0
        end
      end

      def initialize(filename)
        @patterns = []
        p = Pattern.new
        @patterns << p
        p.pattern_number = 1
        n = p.pattern_number
        File.open(filename).each do |line|
          if line == "\n"
            p = Pattern.new
            n += 1
            p.pattern_number = n
            @patterns << p
          else
            p.rows << line.strip
          end
        end

        @patterns.each do |pattern|
          pattern.rows.each do |row|
            row.split('').each_with_index do |char, index|
              pattern.columns[index] ||= String.new
              pattern.columns[index] += char
            end
          end
        end
      end

      def note_summary
        @patterns.collect { |pattern| pattern.mirrored_row_number * 100 }.reduce(:+) + @patterns.collect { |pattern| (pattern.mirrored_column_number) }.reduce(:+)
      end

      def part_1
        @patterns.each { |pattern| pattern.find_mirrors }
        note_summary
      end

      def part_2
        @patterns.each { |pattern| pattern.find_mirrors }
        @patterns.each { |pattern| pattern.find_smudge }
        note_summary
      end
    end
  end
end

a = AdventOfCode::Year2023::Day13.new('aoc13.txt')
#puts a.part_1
puts a.part_2
