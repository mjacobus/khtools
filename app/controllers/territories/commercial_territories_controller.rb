# frozen_string_literal: true

module Territories
  class CommercialTerritoriesController < Territories::TerritoriesController
    model_class Db::CommercialTerritory
  end
end
