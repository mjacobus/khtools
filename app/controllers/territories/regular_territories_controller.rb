# frozen_string_literal: true

module Territories
  class RegularTerritoriesController < Territories::TerritoriesController
    model_class Db::RegularTerritory
  end
end
