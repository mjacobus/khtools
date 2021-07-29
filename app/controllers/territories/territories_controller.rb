# frozen_string_literal: true

class Territories::TerritoriesController < ApplicationController
  def index
    territories = paginate(model_class.all.with_dependencies.search(params))
    render index_page_component(territories)
  end

  def show
    render Territories::ShowPageComponent.new(territory: territory)
  end

  def new
    render form(model_class.new)
  end

  def create
    @territory = model_class.new
    save_territory
  end

  def edit
    render form(territory)
  end

  def update
    save_territory
  end

  def destroy
    territory.destroy
    redirect_to action: :index
  end

  private

  def territory
    @territory ||= model_class.find(params[:id])
  end

  def model_class
    raise 'Abstract method'
  end

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
    params.require(:territory).permit(*attributes)
  end

  def attributes
    model_class.new.editable_attributes
  end

  def index_page_component(territories)
    Territories::IndexPageComponent.new(
      territories: territories,
      title: model_class.model_name.human,
      type: model_class.new.type_key.to_sym
    )
  end
end
