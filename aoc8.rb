module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day08
      attr_accessor :nodes, :instructions

      def initialize(filename)
        @nodes = {}
        lines = File.readlines(filename, chomp: true)
        @instructions = lines[0].strip
        lines[2..-1].each do |line|
          @nodes[line[0..2]] = {
            'L' => line[7..9],
            'R' => line[12..14]
          }
        end
      end

      def part1
        num_steps = 0
        current_instruction = 0
        current_node = '11A'
        while (true)
          current_node = @nodes[current_node][@instructions[current_instruction]]
          num_steps += 1
          return num_steps if current_node == 'ZZZ'
          current_instruction += 1
          current_instruction = 0 if current_instruction >= @instructions.length
        end
      end

      def part2
        # find all nodes that end with A
        starting_nodes = @nodes.keys.select { | key| key.end_with?('A') }
        all_num_steps = []

        starting_nodes.each do |node|
          num_steps = 0
          current_instruction = 0
          current_node = node

          while (true)
            current_node = @nodes[current_node][@instructions[current_instruction]]
            num_steps += 1
            break if current_node.end_with?('Z')
            current_instruction += 1
            current_instruction = 0 if current_instruction >= @instructions.length
          end

          all_num_steps << num_steps
        end

        all_num_steps.uniq.reduce(:lcm)
      end
    end
  end
end

a = AdventOfCode::Year2023::Day08.new('aoc8-2.txt')
a.part2