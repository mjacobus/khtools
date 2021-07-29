# frozen_string_literal: true

module Territories
  class TerritoryNotesComponent < RecordAttributeComponent
    private

    def value
      record.notes
    end

    def icon_name
      'pencil-square'
    end
  end
end
