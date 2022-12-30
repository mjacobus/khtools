# frozen_string_literal: true

require 'koine/url'

module GoogleMaps
  # @see https://developers.google.com/maps/documentation/maps-static/start
  #
  # Relevant params:
  #
  # path:
  # zoom:
  # scale:
  # center:
  class StaticMapUrl < Koine::Url
    def initialize(url = 'https://maps.googleapis.com/maps/api/staticmap')
      super
    end

    def with_api_key(key)
      with_query_param('key', key)
    end

    def with_polygon(coordinates, color: '0x0000ff', weight: 5)
      value = coordinates.to_a.map { |line| line.join(',') }.join('|')
      value = "color:#{color}|weight:#{weight}|#{value}"
      with_query_param('path', value)
    end

    def with_center(lat_lon)
      with_query_param(:center, lat_lon.join(','))
    end
  end
end
