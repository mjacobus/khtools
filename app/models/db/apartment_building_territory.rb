# frozen_string_literal: true

class Db::ApartmentBuildingTerritory < Db::Territory
  validates :address, presence: true
end
