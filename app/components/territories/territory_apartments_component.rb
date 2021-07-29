# frozen_string_literal: true

module Territories
  class TerritoryApartmentsComponent < RecordAttributeComponent
    private

    def value
      if record.apartments
        tag.pre do
          record.apartments
        end
      end
    end

    def icon_name
      'door-closed'
    end
  end
end
