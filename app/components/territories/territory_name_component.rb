# frozen_string_literal: true

class Territories::TerritoryNameComponent < RecordAttributeComponent
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
