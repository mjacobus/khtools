# frozen_string_literal: true

class LocationService
  def initialize(geolocation_service:)
    @geolocation_service = geolocation_service
  end

  def create_by_geolocation(geolocation:, territory:)
    result = first_address_by_geolocation(geolocation)
    location = territory.locations.build(
      street_name: result.street_name,
      number: result.street_number,
      address: result.address,
      latitude: geolocation.latitude,
      longitude: geolocation.longitude
    )
    location.save!
    location
  end

  private

  def first_address_by_geolocation(geolocation)
    geolocation_service.addresses_by_geolocation(geolocation).first
  end

  attr_reader :geolocation_service
end
