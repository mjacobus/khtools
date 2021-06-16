# frozen_string_literal: true

class Territories::CommercialTerritoriesController < ApplicationController
  def index
    territories = paginate(Db::CommercialTerritory.all)
    page = Territories::CommercialTerritories::IndexPageComponent.new(territories)
    render page
  end
end
