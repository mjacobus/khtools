# frozen_string_literal: true

module Territories
  class TerritoryPreachingMethodsComponent < RecordAttributeComponent
    private

    def value
      if record.preaching_method_names.any?
        record.preaching_method_names.join(', ')
      end
    end

    def icon_name
      'briefcase'
    end
  end
end
