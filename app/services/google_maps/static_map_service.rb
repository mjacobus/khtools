# frozen_string_literal: true

require 'koine/url'

# https://developers.google.com/maps/documentation/maps-static/start
module GoogleMaps
  class StaticMapService
    def initialize(api_key:)
      @api_key = api_key
    end

    def url_from_kml(kml_string)
      doc = Nokogiri::XML(kml_string)
      node = doc.css('Polygon outerBoundaryIs LinearRing coordinates')
      coordinates = Kml::Nodes::Coordinates.new(node)

      StaticMapUrl.new
        .with_api_key(@api_key)
        .with_polygon(coordinates.to_a)
        .with_center(coordinates.center)
    end
  end
end
