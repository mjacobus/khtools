# frozen_string_literal: true

module Territories
  class TerritoryApartmentsComponent < RecordAttributeComponent
    private

    def value
      render Territories::ParsedApartmentsComponent.new(apartments: record.parsed_apartments)
    end

    def icon_name
      'door-closed'
    end
  end
end
