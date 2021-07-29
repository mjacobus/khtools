# frozen_string_literal: true

module Territories
  class TerritoryBuildingNameComponent < RecordAttributeComponent
    private

    def value
      record.building_name
    end

    def icon_name
      :star
    end
  end
end
