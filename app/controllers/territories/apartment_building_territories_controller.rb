# frozen_string_literal: true

class Territories::ApartmentBuildingTerritoriesController < ApplicationController
  def index
    territories = paginate(Db::ApartmentBuildingTerritory.all)
    page = Territories::ApartmentBuildingTerritories::IndexPageComponent.new(territories)
    render page
  end
end
