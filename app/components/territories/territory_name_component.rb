# frozen_string_literal: true

module Territories
  class TerritoryNameComponent < RecordAttributeComponent
    private

    def value
      record.name
    end

    def icon_name
      {
        phone_list: :phone,
        commercial: :cart4,
        regular: :map,
        apartment_building: :building
      }.fetch(record.type_key.to_sym)
    end
  end
end
