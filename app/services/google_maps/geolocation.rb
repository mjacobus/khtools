# frozen_string_literal: true

module GoogleMaps
  class Geolocation
    attr_reader :latitude, :longitude

    def initialize(latitude:, longitude:)
      @latitude = Float(latitude)
      @longitude = Float(longitude)
    end
  end
end
