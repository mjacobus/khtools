# frozen_string_literal: true

module Territories
  class TerritoryFieldServiceGroupComponent < RecordAttributeComponent
    private

    def value
      record.field_service_group&.name
    end

    def icon_name
      'people'
    end
  end
end
