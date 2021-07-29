# frozen_string_literal: true

module Territories
  class TerritoryAddressComponent < RecordAttributeComponent
    private

    def value
      record.address
    end

    def icon_name
      'pin-map'
    end
  end
end
