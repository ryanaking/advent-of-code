require 'rgl/adjacency'
require 'rgl/connected_components'

module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day25
      attr_accessor :graph

      class Edge
        attr_accessor :from, :to, :label

        def initialize(from, to, label)
          @from = from
          @to = to
          @label = label
        end
      end

      class Vertex
        attr_accessor :name, :edges

        # Edges is a hash where the key is the destination vertex name and the value is an array of edge objects
        def add_edge(edge)
          @edges[edge.to] ||= []
          @edges[edge.to] << edge
        end

        def remove_edge(other_vertex)
          unless @edges[other_vertex].nil?
            @edges.delete(other_vertex)
          end
        end

        def initialize(name)
          @name = name
          @edges = {}
        end
      end

      class Graph
        attr_accessor :vertices

        def random_edge
          @vertices.values.sample.edges.values.sample.sample
        end

        def connected_components
          g = RGL::AdjacencyGraph.new
          @vertices.each_value do |vertex|
            g.add_vertex(vertex.name)
            vertex.edges.each_value do |edge_list|
              edge_list.each do |edge|
                g.add_edge(edge.from, edge.to)
              end
            end
          end
          connected_components = []
          g.each_connected_component do |c|
            connected_components << c
          end
          connected_components
        end

        # add edge between two vertices, creating the vertices if they don't exist
        # by default the label will be assigned as 'from-to' but can be overridden
        def add_edge(vertex1, vertex2, label=nil)
          add_vertex(Vertex.new(vertex1)) unless @vertices[vertex1]
          add_vertex(Vertex.new(vertex2)) unless @vertices[vertex2]
          @vertices[vertex1].add_edge(Edge.new(vertex1, vertex2, label ? label : "#{vertex1}-#{vertex2}"))
          @vertices[vertex2].add_edge(Edge.new(vertex2, vertex1, label ? label : "#{vertex2}-#{vertex1}"))
        end

        def remove_edge(vertex1, vertex2)
          if @vertices[vertex1].edges.has_key?(vertex2)
            @vertices[vertex1].edges.delete(vertex2)
          end
          if @vertices[vertex2].edges.has_key?(vertex1)
            @vertices[vertex2].edges.delete(vertex1)
          end
        end

        def add_vertex(vertex)
          @vertices[vertex.name] = vertex
        end

        def remove_vertex(vertex_name)
          # remove all edges from any vertex TO this vertex
          @vertices.each_value do |vertex|
            vertex.remove_edge(vertex_name)
          end
          @vertices.delete(vertex_name)
        end

        def initialize
          @vertices = {}
        end
      end

      def initialize(filename)
        @graph = Graph.new
        File.open(filename).each_with_index do |line, i|
          from_vertex_name = line.split(':').first
          to_vertex_list = line.split(':').last.split(' ')
          to_vertex_list.each do |to_vertex_name|
            @graph.add_edge(from_vertex_name, to_vertex_name)
          end
        end
      end

      # Karger's Algorithm - "contract" two nodes in the graph https://en.wikipedia.org/wiki/Karger%27s_algorithm
      def contract(graph, vertex1, vertex2)
        graph.vertices[vertex2].edges.each_value do |edge_list|
          edge_list.each do |edge|
            graph.add_edge(vertex1, edge.to, edge.label) if edge.to != vertex1
          end
        end
        graph.remove_vertex(vertex2)
        graph
      end

      # Karger's Algorithm - Keep picking random edges in the graph and contracting the connected vertices from that edge
      # until there are only two vertices left https://en.wikipedia.org/wiki/Karger%27s_algorithm
      def karger(graph)
        while graph.vertices.count > 2
          edge = graph.random_edge
          graph = contract(graph, edge.from, edge.to)
        end
        graph
      end

      # Karger's Algorithm - repeat the above algorithm up to (n^2 log n) times to find the minimum cut (with high probability)
      # where n is the # of vertices in the graph https://en.wikipedia.org/wiki/Karger%27s_algorithm
      # This is a modified version because we know a priori we are looking for a cut size of 3
      # so we can stop when we find that
      def karger_n2_log_n(g)
        (g.vertices.size ** 2 * Math.log(g.vertices.values.size)).to_i.times do
          g_copy = Marshal.load(Marshal.dump(g))
          reduced_graph = karger(g_copy)
          if reduced_graph.vertices.values.first.edges.values.first.size <= 3
            return reduced_graph
          end
        end
        nil
      end

      def part_1
        # run the Karger Algorithm on the Graph to find the 'minimum cut'  https://en.wikipedia.org/wiki/Minimum_cut
        result = karger_n2_log_n(@graph)

        # now cut the original graph according to the karger algo result by removing edges that match the labels of the edges in the result
        result.vertices.first[1].edges.values[0].collect { |c| c.label }
        result.vertices.first[1].edges.values[0].each do |edge|
          puts "removing edge #{edge.label.split('-')[0]} -> #{edge.label.split('-')[1]}"
          @graph.remove_edge(edge.label.split('-')[0], edge.label.split('-')[1])
        end

        # finally multiply the sizes of the connected components together to get the answer
        @graph.connected_components.collect { |c| c.size }.inject(:*)
      end

      def part_2

      end
    end
  end
end

a = AdventOfCode::Year2023::Day25.new('aoc25.txt')
puts a.part_1
#puts a.part_2
