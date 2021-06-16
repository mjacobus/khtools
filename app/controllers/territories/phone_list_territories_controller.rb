# frozen_string_literal: true

class Territories::PhoneListTerritoriesController < ApplicationController
  def index
    territories = Db::PhoneListTerritory.all.limit(5)
    page = Territories::PhoneListTerritories::IndexPageComponent.new(territories)
    render page
  end
end
