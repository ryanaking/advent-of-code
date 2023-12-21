module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day19
      attr_accessor :workflows, :parts, :workflow_graph

      class Vertex
        attr_accessor :name, :edges, :version

        def initialize(name)
          @name = name
          @edges = []
          @version = 1
        end
      end

      class Edge
        attr_accessor :from, :to, :conditions

        def initialize(from, to, conditions)
          @from = from
          @to = to
          @conditions = conditions
        end
      end

      class Graph
        attr_accessor :vertices

        def initialize
          @vertices = {}
        end
      end

      class Condition
        attr_accessor :category, :operator, :value

        def initialize(condition_text)
          @category = condition_text[0]
          @operator = condition_text[1]
          @value = condition_text[2..-1].to_i
        end

        def opposite_condition
          c = self.dup
          c.operator = opposite_operator
          c
        end

        def opposite_operator
          case @operator
          when '<'
            '>='
          when '>'
            '<='
          end
        end

        def to_s
          "#{@category} #{@operator} #{@value}"
        end
      end

      class Rule
        attr_accessor :condition, :action

        def initialize(rule_text)
          if rule_text.include? ':'
            @condition = Condition.new(rule_text.split(':')[0].strip)
            @action = rule_text.split(':')[1].strip
          else
            @condition = nil
            @action = rule_text
          end
        end

        def accept?
          @action == 'A'
        end

        def reject?
          @action == 'R'
        end

        def next_workflow
          (@action != 'A' && @action != 'R') ? @action : nil
        end

        def opposing_conditions(rules)
          opp = []
          # rules are processed in order
          # so to create an opposing conditions list to this rule
          # we need to take all the conditions that come before this one and negate them
          rules.each do |rule|
            if rule == self
              opp << @condition if @condition
              break
            end
            opp << rule.condition.opposite_condition
          end
          opp
        end
      end

      class Workflow
        attr_accessor :name, :rules

        def initialize(line)
          @name = line.split('{')[0]
          @rules = []
          line[0..-2].split('{')[1].split(',').each do |rule_part|
            @rules << Rule.new(rule_part)
          end
        end

        def process!(part)
          @rules.each do |rule|
            if rule.condition.nil? || part.satisfies_condition?(rule.condition)
              if rule.accept?
                part.status = :accepted
                return nil
              elsif rule.reject?
                part.status = :rejected
                return nil
              else
                return rule.next_workflow
              end
            end
          end

          part.status = :accepted if part.status == :unknown
        end
      end

      class Part
        attr_accessor :x, :m, :a, :s, :status

        def initialize(line)
          @status = :unknown
          line[1..-2].split(',').each do |part_value|
            case part_value[0]
            when 'x'
              @x = part_value[2..-1].to_i
            when 'm'
              @m = part_value[2..-1].to_i
            when 'a'
              @a = part_value[2..-1].to_i
            when 's'
              @s = part_value[2..-1].to_i
            end
          end
        end

        def satisfies_condition?(condition)
          case condition.operator
          when '<'
            self.send(condition.category.to_sym) < condition.value
          when '>'
            self.send(condition.category.to_sym) > condition.value
          end
        end

        def total_value
          @status == :accepted ? x + m + a + s : 0
        end
      end

      def initialize(filename)
        @workflows = {}
        @parts = []
        @accepted_parts = []
        parse_workflow = true
        File.open(filename).each_with_index do |line, y|
          parse_workflow = false if line.chomp == ''

          if parse_workflow
            w = Workflow.new(line.chomp)
            @workflows[w.name] = w
          else
            @parts << Part.new(line.chomp) if line.chomp.length > 0
          end
        end
      end

      def process!
        @parts.each do |part|
          workflow_name = 'in'
          while part.status == :unknown
            workflow_name =  @workflows[workflow_name].process!(part)
          end
        end
      end

      def part_1
        process!
        @parts.map(&:total_value).inject(:+) || 0
      end

      # recursive function that builds the graph underneath the given workflow
      def build_graph_from_workflow(workflow_name)
        @workflows[workflow_name].rules.each do |rule|
          e = Edge.new(workflow_name, rule.action, rule.opposing_conditions(@workflows[workflow_name].rules))
          #puts "build_graph_from_workflow #{workflow_name}: rule #{rule.inspect} adding edge #{e.inspect}"
          @workflow_graph.vertices[workflow_name].edges << e
          if rule.next_workflow
            build_graph_from_workflow(rule.next_workflow)
          end
        end
      end

      def build_graph
        @workflow_graph = Graph.new
        @workflows.each do |name, workflow|
          @workflow_graph.vertices[name] = Vertex.new(name)
        end

        build_graph_from_workflow('in')
      end

      # recurisve method to build all the paths from the given vertex to the 'A' exit leaf
      def build_accept_paths(name)
        paths = []
        @workflow_graph.vertices[name].edges.each do |edge|
          if edge.to == 'A'
            paths << [edge]
          elsif edge.to == 'R'
            # do nothing
            #
          else
            sub_paths = build_accept_paths(edge.to)
            unless sub_paths.nil?
              sub_paths.each do |path|
                unless path.nil?
                  paths << [edge] + path
                end
              end
            end
          end
        end
        paths
      end

      def part_2
        sum_of_accepted = 0

        # create a directed graph of workflows
        build_graph

        # find all paths from 'in' to 'A'
        paths_to_accept = build_accept_paths('in')

        # for each path from 'in' to 'A'
        paths_to_accept.each do |path|
          #puts "path_to_accept: in->#{path.map(&:to).join('->')}"
           # assuming 1-4000 as possible starting values for x, m, a, s
          starting_values = {}
          ending_values = {}
          ['a', 'm', 'x', 's'].each { |c| starting_values[c] = 1 }
          ['a', 'm', 'x', 's'].each { |c| ending_values[c] = 4000 }

          # figure out the subset of the 4000^4 possible starting values that satisfy the conditions along that path
          path.each do |edge|
            edge.conditions.each do |condition|
              case condition.operator
              when '<'
                ending_values[condition.category] = [ending_values[condition.category], condition.value - 1].min
              when '<='
                ending_values[condition.category] = [ending_values[condition.category], condition.value].min
              when '>='
                starting_values[condition.category] = [starting_values[condition.category], condition.value].max
              when '>'
                starting_values[condition.category] = [starting_values[condition.category], condition.value + 1].max
              end
            end
          end

          sum_of_accepted += (ending_values['x'] - starting_values['x'] + 1) * (ending_values['m'] - starting_values['m'] + 1) * (ending_values['a'] - starting_values['a'] + 1) * (ending_values['s'] - starting_values['s'] + 1)
        end

        sum_of_accepted
      end
    end
  end
end

a = AdventOfCode::Year2023::Day19.new('aoc19.txt')
puts a.part_1
puts a.part_2
