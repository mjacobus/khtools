# frozen_string_literal: true

class Territories::ApartmentBuildingTerritories::IndexPageComponent < Territories::RegularTerritories::IndexPageComponent
  private

  def model
    Db::ApartmentBuildingTerritory
  end

  def type
    :apartment_building
  end
end
