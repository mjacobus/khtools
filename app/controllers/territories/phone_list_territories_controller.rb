# frozen_string_literal: true

class Territories::PhoneListTerritoriesController < Territories::TerritoriesController
  private

  def index_page_class
    Territories::PhoneListTerritories::IndexPageComponent
  end

  def model_class
    Db::PhoneListTerritory
  end

  def attributes
    %i[
      name
      initial_phone_number
      final_phone_number
      phone_provider_id
      assignee_id
      assigned_at
    ]
  end
end
