# frozen_string_literal: true

class Territories::RegularTerritoriesController < ApplicationController
  def index
    territories = Db::RegularTerritory.all
    page = Territories::RegularTerritories::IndexPageComponent.new(territories)
    render page
  end
end