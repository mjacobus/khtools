# frozen_string_literal: true

module Territories
  class ApartmentBuildingTerritoriesController < Territories::TerritoriesController
    model_class Db::ApartmentBuildingTerritory
  end
end
