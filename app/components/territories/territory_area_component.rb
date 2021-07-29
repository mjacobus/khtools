# frozen_string_literal: true

module Territories
  class TerritoryAreaComponent < RecordAttributeComponent
    private

    def value
      record.area_name
    end

    def icon_name
      'pin-map'
    end
  end
end
