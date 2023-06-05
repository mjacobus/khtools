# frozen_string_literal: true

class Territories::RegularTerritoriesController < Territories::TerritoriesController
  model_class Db::RegularTerritory

  skip_before_action :require_authorization, only: [:public_show]

  def printable
    territory = current_user.account.territories.regular.find(params[:regular_territory_id])
    @component = Territories::PrintableTerritoryPageComponent.new(territory: territory)
    export_pdf(territory.filename('pdf'), header: { right: territory.name })
  end

  def public_show
    territory = Db::Territory.regular.by_id_and_public_view_token(
      params[:regular_territory_id],
      params[:token]
    )
    render Territories::PublicShowPageComponent.new(territory: territory)
  end
end
