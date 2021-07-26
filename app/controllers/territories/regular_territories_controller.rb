# frozen_string_literal: true

class Territories::RegularTerritoriesController < Territories::TerritoriesController
  private

  def index_page_class
    Territories::RegularTerritories::IndexPageComponent
  end

  def model_class
    Db::RegularTerritory
  end
end
