# frozen_string_literal: true

module Territories
  class TerritoryTerritoryComponent < RecordAttributeComponent
    private

    def value
      record.territory&.name
    end

    def icon_name
      'map'
    end
  end
end
