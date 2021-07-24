# frozen_string_literal: true

class Territories::CommercialTerritoriesController < Territories::TerritoriesController
  private

  def index_page_class
    Territories::CommercialTerritories::IndexPageComponent
  end

  def model_class
    Db::CommercialTerritory
  end

  def attributes
    %i[name assignee_id assigned_at]
  end
end
