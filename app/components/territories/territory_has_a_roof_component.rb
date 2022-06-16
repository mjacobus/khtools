# frozen_string_literal: true

module Territories
  class TerritoryHasARoofComponent < RecordAttributeComponent
    private

    def value
      t(record.has_a_roof.to_s) unless record.has_a_roof.nil?
    end

    def icon_name
      'umbrella'
    end
  end
end
