# frozen_string_literal: true

class Territories::PublicShowPageComponent < ApplicationComponent
  include TerritoryAttributesConcern

  has :territory
end
