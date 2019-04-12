require 'open3'

module Statesman
  class Diagram
    # @param [String] name  - name of the diagram.
    # @param [Hash]   graph - list of vertices and edges.
    def initialize(name:, graph:)
      @name  = name
      @graph = graph
    end

    # @return [String] diagram in DOT format.
    def to_dot
      format("digraph %{name} {\n  %{body}\n}", name: @name, body: dot_body.join("\n  "))
    end

    def to_svg(file_name = nil)
      file_name ||= @name
      file_name += '.svg'

      build_svg(file_name)
    end

    private

    # @return [String]
    def dot_body
      @graph.map do |vertex, edges|
        vertex == "derailed" ? [] :
        edges.select { |edge| edge != "derailed" }.map do |to|
          "#{vertex} -> #{to};"
        end
      end.flatten
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
