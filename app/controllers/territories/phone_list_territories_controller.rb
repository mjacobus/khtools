# frozen_string_literal: true

class Territories::PhoneListTerritoriesController < Territories::TerritoriesController
  private

  def index_page_class
    Territories::PhoneListTerritories::IndexPageComponent
  end

  def model_class
    Db::PhoneListTerritory
  end
end
