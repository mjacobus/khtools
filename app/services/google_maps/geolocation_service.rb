# frozen_string_literal: true

module GoogleMaps
  class GeolocationService
    def initialize(client = Client.create)
      @client = client
    end

    def addresses_by_geolocation(geolocation)
      result = @client.get('/geocode/json',
                           latlng: "#{geolocation.latitude},#{geolocation.longitude}")
      result['results'].map do |item|
        GeocodingResult.create(item)
      end
    end

    private

    attr_reader :client
  end
end
