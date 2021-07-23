# frozen_string_literal: true

class Territories::PhoneListTerritoriesController < Territories::TerritoriesController
  def index
    territories = paginate(Db::PhoneListTerritory.all.with_dependencies.search(params))
    page = Territories::PhoneListTerritories::IndexPageComponent.new(territories)
    render page
  end

  def new
    render form(Db::PhoneListTerritory.new)
  end

  def create
    @territory = Db::PhoneListTerritory.new
    save_territory
  end

  def edit
    render Territories::FormPageComponent.new(
      territory: territory
    )
  end

  def update
    save_territory
  end

  def destroy
    territory.destroy
    redirect_to action: :index
  end

  private

  def save_territory
    territory.attributes = territory_attributes

    if territory.save
      redirect_to action: :index
      return
    end

    render form(territory), status: :unprocessable_entity
  end

  def form(territory)
    Territories::FormPageComponent.new(territory: territory)
  end

  def territory_attributes
    params.require(:territory).permit(
      :name,
      :initial_phone_number,
      :final_phone_number,
      :phone_provider_id,
      :assignee_id,
      :assigned_at
    )
  end
end
