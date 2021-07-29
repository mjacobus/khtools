# frozen_string_literal: true

module Territories
  class TerritoryIntercomTypeComponent < RecordAttributeComponent
    private

    def value
      record.intercom_type&.name
    end

    def icon_name
      'soundwave'
    end
  end
end
