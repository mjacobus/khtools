# frozen_string_literal: true

class Territories::PhoneListTerritoriesController < Territories::TerritoriesController
  model_class Db::PhoneListTerritory

  def xls
    spreadsheet = PhoneListTerritoryService.new.create_spreadsheet(territory)
    send_data(spreadsheet.to_stream.read, filename: territory.filename('xls'))
  end

  def pdf
    @component = Territories::PhoneListPdfComponent.new(territory: territory)
    export_pdf(territory.filename('pdf'), orientation: 'Landscape')
  end

  private

  def territory
    @territory ||= Db::PhoneListTerritory.find(params[:id])
  end
end
