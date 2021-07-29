# frozen_string_literal: true

module Territories
  class TerritoryHasARoofComponent < RecordAttributeComponent
    private

    def value
      unless record.has_a_roof.nil?
        t(record.has_a_roof.to_s)
      end
    end

    def icon_name
      'umbrella'
    end
  end
end
