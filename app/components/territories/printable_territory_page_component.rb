# frozen_string_literal: true

class Territories::PrintableTerritoryPageComponent < ApplicationComponent
  has :territory

  def display_static_map?
    !display_file? && territory.has_static_map?
  end

  def display_file?
    territory.file.present?
  end
end
