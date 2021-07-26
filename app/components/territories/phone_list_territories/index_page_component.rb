# frozen_string_literal: true

class Territories::PhoneListTerritories::IndexPageComponent < Territories::RegularTerritories::IndexPageComponent
  private

  def model
    Db::PhoneListTerritory
  end

  def type
    :phone_list
  end
end
