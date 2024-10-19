# frozen_string_literal: true

class Territories::Locations::FormComponent < PageComponent
  has :territory
  has :location

  def target_url
    if location.id
      return urls.territory_location_path(location)
    end

    urls.territory_locations_path(territory:)
  end
end
