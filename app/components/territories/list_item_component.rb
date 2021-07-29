# frozen_string_literal: true

class Territories::ListItemComponent < ApplicationComponent
  include TerritoryAttributesConcern

  attr_reader :territory

  def initialize(territory)
    @territory = territory
  end
end
