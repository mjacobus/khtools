# frozen_string_literal: true

module Territories
  class TerritoryAssigneeComponent < RecordAttributeComponent
    private

    def value
      record.assignee&.name
    end

    def icon_name
      'person'
    end
  end
end
