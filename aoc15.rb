module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day15
      attr_accessor :instructions, :boxes

      class Instruction
        attr_accessor :label, :operation, :focal_length, :box_number, :raw_input

        def initialize(input)
          @raw_input = input
          parts = input.split(/[\-,=]/)
          @label = parts[0]
          @operation = input.include?('-') ? :delete : :add
          if @operation == :add
            @focal_length = parts[1].to_i
          end
          @box_number = Instruction.compute_hash(@label)
        end

        class << self
          def compute_hash(s)
            h = 0
            s.each_byte do |c|
              h += c
              h *= 17
              h = h % 256
            end
            h
          end
        end
      end

      class Lens
        attr_accessor :label, :focal_length

        def initialize(label, focal_length)
          @label = label
          @focal_length = focal_length
        end
      end

      class Box
        attr_accessor :box_number, :lenses

        def initialize(box_number)
          @box_number = box_number
          @lenses = []
        end

        def add(label, focal_length)
          puts "adding #{focal_length} to box #{@box_number} with label #{label}"
          @lenses.each do |lens|
            if lens.label == label
              lens.focal_length = focal_length
              return
            end
          end
          @lenses << Lens.new(label, focal_length)
        end

        def delete(label)
          puts "deleting #{label} from box #{@box_number}"
          @lenses.each_with_index do |lens, index|
            if lens.label == label
              @lenses.delete_at(index)
              return
            end
          end
        end

        def to_s
          unless @lenses.empty?
            s = "Box #{@box_number}: "
            @lenses.each do |lens|
              s += "[#{lens.label} #{lens.focal_length}] "
            end
          end
          s
        end
      end

      def initialize(filename)
        @instructions = []
        File.open(filename).each do |line|
          sequence = line.strip.split(',')
          sequence.each do |s|
            @instructions << Instruction.new(s)
          end
        end
        @boxes = {}
        puts "instructions = #{@instructions}"
      end

      def compute_hash_sum
        sum = 0
        @instructions.each do |s|
          sum += Instruction.compute_hash(s.raw_input)
        end
        sum
      end

      def initialize_boxes
        @instructions.each do |instruction|
          box = @boxes[instruction.box_number]

          if box.nil?
            box ||= Box.new(instruction.box_number)
          end

          if instruction.operation == :add
            box.add(instruction.label, instruction.focal_length)
          else
            box.delete(instruction.label)
          end

          @boxes[instruction.box_number] = box
        end
        @boxes.each_value do |box|
          puts "#{box.to_s}"
        end
      end

      def total_focusing_power
        total = 0
        @boxes.each_value do |box|
          box.lenses.each_with_index do |lens, slot|
            total += (1 + box.box_number) * (slot + 1) * lens.focal_length
          end
        end
        total
      end

      def part_1
        compute_hash_sum
      end

      def part_2
        initialize_boxes
        total_focusing_power
      end
    end
  end
end

a = AdventOfCode::Year2023::Day15.new('aoc15.txt')
#puts a.part_1
puts a.part_2
