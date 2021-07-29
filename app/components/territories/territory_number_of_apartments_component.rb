# frozen_string_literal: true

module Territories
  class TerritoryNumberOfApartmentsComponent < RecordAttributeComponent
    private

    def value
      record.number_of_apartments.to_s
    end

    def icon_name
      'door-closed'
    end
  end
end
