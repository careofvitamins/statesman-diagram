require 'open3'

module Statesman
  class Diagram
    # @param [String] name  - name of the diagram.
    # @param [Hash]   graph - list of vertices and edges.
    def initialize(name:, graph:)
      @name  = name
      @graph = graph
      @vertex_to_remove = "derailed"
    end

    # @return [String] diagram in DOT format.
    def to_dot
      format("digraph %{name} {\n  %{body}\n}", name: @name, body: dot_body.join("\n  "))
    end

    def to_svg(file_name = nil)
      file_name ||= @name

      @filtered = false
      build_svg(file_name + '.svg')

      return unless @graph.key?(@vertex_to_remove)

      @filtered = true
      file_name += '_filtered'
      build_svg(file_name + '.svg')
    end

    private

    # @return [String]
    def dot_body
      @graph.map do |vertex, edges|
        (@filtered && vertex == @vertex_to_remove) ? [] :
        edges.select { |edge|
          keep_edge?(vertex, edge)
        }.map do |to|
          "#{vertex} -> #{to};"
        end
      end.flatten
    end

    def keep_edge?(vertex, edge)
      return true if not @filtered
      return false if edge == @vertex_to_remove
      return true if edge != "shipped"

      ["packed", "proteins_packed"].include?(vertex)
    end

    def build_svg(file_name)
      cmd = ['dot', '-Tsvg', "-o#{file_name}"]

      puts "Running '#{cmd.join(' ')}' with this ^ as stdin..."

      output, status = Open3.capture2e(*cmd, stdin_data: to_dot)
      if status.success?
        puts "Success. You can open #{file_name} and see the diagram."
      else
        puts 'The command failed:'
        puts output
      end
    end
  end
end
