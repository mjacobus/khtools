# frozen_string_literal: true

class Territories::PhoneListTerritoriesController < Territories::TerritoriesController
  def index
    territories = paginate(Db::PhoneListTerritory.all.with_dependencies.search(params))
    page = Territories::PhoneListTerritories::IndexPageComponent.new(territories)
    render page
  end

  def edit
    render Territories::FormPageComponent.new(
      territory: territory
    )
  end

  def update
    if territory.update(territory_attributes)
      redirect_to action: :index
      return
    end

    render form(territory), status: :unprocessable_entity
  end

  def new
    render form(Db::PhoneListTerritory.new)
  end

  private

  def form(territory)
    Territories::FormPageComponent.new(territory: territory)
  end

  def territory_attributes
    params.require(:territory).permit(
      :name,
      :initial_phone_number,
      :final_phone_number,
      :assignee_id,
      :assigned_at
    )
  end
end
