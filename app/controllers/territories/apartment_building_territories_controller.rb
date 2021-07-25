# frozen_string_literal: true

class Territories::ApartmentBuildingTerritoriesController < Territories::TerritoriesController
  private

  def index_page_class
    Territories::ApartmentBuildingTerritories::IndexPageComponent
  end

  def model_class
    Db::ApartmentBuildingTerritory
  end

  def attributes
    %i[
      name
      assigned_at
      returned_at
      created_at
      updated_at
      assignee_id
      address
      building_name
      number_of_apartments
      has_a_roof
      intercom_type
      apartments
      notes
      territory_id
      area_id
      intercom_type_id
      letter_box_type_id
      primary_preaching_method_id
      secondary_preaching_method_id
      tertiary_preaching_method_id
    ]
  end
end
