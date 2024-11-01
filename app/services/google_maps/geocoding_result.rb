# frozen_string_literal: true

module GoogleMaps
  class GeocodingResult
    attr_reader :street_number,
                :street_name,
                :city,
                :state,
                :country,
                :postal_code,
                :latitude,
                :longitude,
                :formatted_address

    def initialize(street_number:, street_name:, city:, state:, country:, postal_code:, geolocation:,
                   formatted_address:)
      @street_number = street_number
      @street_name = street_name
      @city = city
      @state = state
      @country = country
      @postal_code = postal_code
      @geolocation = geolocation
      @formatted_address = formatted_address
    end

    def self.create(result_item)
      address_components = result_item['address_components']

      # Extracting meaningful address components
      street_number = find_component(address_components, 'street_number')
      street_name = find_component(address_components, 'route')
      city = find_component(address_components, 'administrative_area_level_2')
      state = find_component(address_components, 'administrative_area_level_1')
      country = find_component(address_components, 'country')
      postal_code = find_component(address_components, 'postal_code')

      # Extracting geometry (latitude and longitude)
      location = result_item['geometry']['location']
      latitude = location['lat']
      longitude = location['lng']

      # Formatted address
      formatted_address = result_item['formatted_address']

      new(
        street_number:,
        street_name:,
        city:,
        state:,
        country:,
        postal_code:,
        geolocation: Geolocation.new(latitude:, longitude:),
        formatted_address:
      )
    end

    def address
      "#{@street_number} #{@street_name}, #{@city}, #{@state}, #{@postal_code}, #{@country}"
    end

    def self.find_component(components, type)
      component = components.find { |c| c['types'].include?(type) }
      component ? component['long_name'] : nil
    end
  end
end
