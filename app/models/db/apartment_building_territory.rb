# frozen_string_literal: true

class Db::ApartmentBuildingTerritory < Db::Territory
  validates :address, presence: true

  # rubocop:disable Metrics/MethodLength
  def editable_attributes
    super + %i[
      address
      building_name
      number_of_apartments
      has_a_roof
      intercom_type
      apartments
      territory_id
      area_id
      intercom_type_id
      letter_box_type_id
      primary_preaching_method_id
      secondary_preaching_method_id
      tertiary_preaching_method_id
    ]
  end
  # rubocop:enable Metrics/MethodLength
end
