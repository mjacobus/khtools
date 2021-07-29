# frozen_string_literal: true

class Territories::CommercialTerritories::IndexPageComponent < Territories::RegularTerritories::IndexPageComponent
  private

  def model
    Db::ApartmentBuildingTerritory
  end

  def type
    :commercial
  end
end
