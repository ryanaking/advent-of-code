$low_pulses = 0
$high_pulses = 0
$queue = []
$low_pulses_for_rx = 0

module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day20
      attr_accessor :modules

      class ModuleConfiguration
        attr_accessor :type, :name, :destinations, :state, :last_pulses

        def initialize(line)
          @state = :off
          @last_pulses = {}
          if ['%', '&'].include?(line[0])
            @type = line[0]
            @name = line[1..-1].split(' ')[0].strip
          else
            @name = line.split(' ')[0].strip
          end
          @destinations = []
          line.split('>')[1].strip.split(',').each do |destination|
            @destinations << destination.strip
          end
        end

        def propagate!(pulse_type)
          @destinations.each do |destination|
            #puts "#{@name}: adding #{destination} #{pulse_type} to queue"
            $queue.unshift [@name, destination, pulse_type]
          end
        end

        def process!(source, pulse_type)
          #puts "#{source} -#{pulse_type}-> #{@name}"

          if pulse_type == :low
            $low_pulses += 1
            $low_pulses_for_rx += 1 if @name == 'rx'
          else
            $high_pulses += 1
          end

          new_pulse_type = pulse_type

          if @name == 'broadcaster'
            propagate!(new_pulse_type)
          elsif @type == '%'
            if pulse_type == :low
              @state = @state == :off ? :on : :off
              propagate!(@state == :on ? :high : :low)
            end
          elsif @type == '&'
            @last_pulses[source] = pulse_type
            #puts "#{@name}: last_pulses = #{@last_pulses}"
            if @last_pulses.values.all?(:high)
              new_pulse_type = :low
            else
              new_pulse_type = :high
            end
            propagate!(new_pulse_type)
          else
            # no op
          end
        end
      end

      def initialize(filename)
        @modules = {}
        File.open(filename).each do |line|
          m = ModuleConfiguration.new(line.strip)
          @modules[m.name] = m
        end
        @modules.each_value do |input_mod|
          @modules.each_value do |output_mod|
            if output_mod.type == '&'
              if input_mod.destinations.include?(output_mod.name)
                output_mod.last_pulses[input_mod.name] = :low
              end
            end
          end
        end
        puts @modules.inspect
      end

      def clear_last_pulses!
        @modules.each_value do |mod|
          mod.last_pulses = {}
        end
      end
      def process_queue!
        while $queue.length > 0
          source, destination, pulse_type = $queue.pop
          mod = @modules[destination]
          if mod
            mod.process!(source, pulse_type)
          else
            #puts "#{source} -#{pulse_type}-> #{destination}"
            $low_pulses += 1 if pulse_type == :low
            $high_pulses += 1 if pulse_type == :high
          end
        end
      end

      def part_1
        1000.times do
          @modules['broadcaster'].process!('button', :low)
          process_queue!
          puts '--------------'
        end
        puts "low pulses = #{$low_pulses}"
        puts "high pulses = #{$high_pulses}"
        $low_pulses * $high_pulses
      end

      def part_2
        count = 0
        while $low_pulses_for_rx != 1
          count += 1
          $low_pulses_for_rx = 0
          @modules['broadcaster'].process!('button', :low)
          process_queue!
          #puts "low pulses for rx = #{$low_pulses_for_rx} #{count}"
        end
        count
      end
    end
  end
end

a = AdventOfCode::Year2023::Day20.new('aoc20.txt')
#puts a.part_1
puts a.part_2
