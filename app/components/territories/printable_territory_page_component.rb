# frozen_string_literal: true

class Territories::PrintableTerritoryPageComponent < ApplicationComponent
  has :territory

  def display_static_map?
    territory.has_static_map?
  end
end
