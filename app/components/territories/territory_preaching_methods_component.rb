# frozen_string_literal: true

module Territories
  class TerritoryPreachingMethodsComponent < RecordAttributeComponent
    private

    def value
      record.preaching_method_names.join(', ') if record.preaching_method_names.any?
    end

    def icon_name
      'briefcase'
    end
  end
end
