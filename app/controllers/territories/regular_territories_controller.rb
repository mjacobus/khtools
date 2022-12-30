# frozen_string_literal: true

class Territories::RegularTerritoriesController < Territories::TerritoriesController
  model_class Db::RegularTerritory

  def printable
    territory = current_user.account.territories.regular.find(params[:regular_territory_id])
    @component = Territories::PrintableTerritoryPageComponent.new(territory: territory)
    export_pdf(territory.filename('pdf'), header: { right: territory.name })
  end
end
