# frozen_string_literal: true

module GoogleMaps
  module Kml
    module Nodes
      class Coordinates
        def initialize(node)
          @node = node
        end

        def values
          @values ||= @node.text.split("\n").map(&:strip).compact_blank.map do |line|
            line.split(',').map { |item| Float(item) }
          end
        end

        def to_a
          values.map { |line| line[0..1] }
        end

        def center
          sorted_x = to_a.map { |(x, _)| x }.sort
          sorted_y = to_a.map { |(_, y)| y }.sort
          [mid(sorted_x), mid(sorted_y)]
        end

        private

        def mid(array)
          first = array.first
          last = array.last
          (last - first) / 2
        end
      end
    end
  end
end
