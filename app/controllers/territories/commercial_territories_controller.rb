# frozen_string_literal: true

class Territories::CommercialTerritoriesController < Territories::TerritoriesController
  private

  def index_page_class
    Territories::CommercialTerritories::IndexPageComponent
  end

  def model_class
    Db::CommercialTerritory
  end
end
