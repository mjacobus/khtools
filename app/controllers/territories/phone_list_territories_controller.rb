# frozen_string_literal: true

class Territories::PhoneListTerritoriesController < ApplicationController
  def index
    territories = paginate(Db::PhoneListTerritory.all)
    page = Territories::PhoneListTerritories::IndexPageComponent.new(territories)
    render page
  end
end
