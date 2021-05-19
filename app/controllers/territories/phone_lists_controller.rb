# frozen_string_literal: true

class Territories::PhoneListsController < ApplicationController
  def xls
    territory = Db::PhoneListTerritory.find(params[:id])
    spreadsheet = PhoneListTerritoryService.new.create_spreadsheet(territory)
    send_data(spreadsheet.to_stream.read, filename: "#{territory.name}.xls")
  end
end
