# frozen_string_literal: true

class Territories::ApartmentBuildingTerritoriesController < Territories::TerritoriesController
  private

  def index_page_class
    Territories::ApartmentBuildingTerritories::IndexPageComponent
  end

  def model_class
    Db::ApartmentBuildingTerritory
  end
end
