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
            line.split(',')[0..1].reverse.map { |item| Float(item) }
          end
        end

        # @return [ [lat1, lon1], [lat2, lon2], ... ]
        def to_a
          values
        end

        # @return [lat, lon]
        def center
          sorted_x = to_a.map { |(x, _)| x }.sort
          sorted_y = to_a.map { |(_, y)| y }.sort
          [mid(sorted_x), mid(sorted_y)]
        end

        private

        def mid(array)
          first = array.first
          last = array.last
          diff = (last - first) / 2
          first + diff
        end
      end
    end
  end
end
