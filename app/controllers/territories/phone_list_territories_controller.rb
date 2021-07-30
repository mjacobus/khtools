# frozen_string_literal: true

class Territories::PhoneListTerritoriesController < Territories::TerritoriesController
  def xls
    territory = Db::PhoneListTerritory.find(params[:id])
    spreadsheet = PhoneListTerritoryService.new.create_spreadsheet(territory)
    send_data(spreadsheet.to_stream.read, filename: "#{territory.name}.xls")
  end

  private

  def index_page_class
    Territories::PhoneListTerritories::IndexPageComponent
  end

  def model_class
    Db::PhoneListTerritory
  end
end
