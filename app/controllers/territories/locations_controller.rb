# frozen_string_literal: true

class Territories::LocationsController < ApplicationController
  def index
    render Territories::Locations::IndexPageComponent.new(
      territory:,
      locations: territory.locations
    )
  end

  def new
    if geolocation
      @location = territory.create_location_by_geolocation(geolocation)
      return redirect_to(action: :edit, id: location.id)
    end

    @location = territory.locations.build
    render Territories::Locations::NewPageComponent.new(territory:, location:)
  rescue StandardError
    flash.now[:error] = 'Erro ao criar localização automaticamente'
    @location = territory.locations.build
    render Territories::Locations::NewPageComponent.new(territory:, location:)
  end

  def edit
    render Territories::Locations::EditPageComponent.new(territory:, location:)
  end

  def create
    @location = territory.locations.build
    @location.update!(payload)
    flash[:success] = 'Localização criada com sucesso'
    redirect_to(action: :index)
  rescue ActiveRecord::RecordInvalid => exception
    @location = exception.record
    @location = territory.locations.build
    render Territories::Locations::NewPageComponent.new(territory:, location:)
  end

  def update; end

  def destroy
    # TODO:
  end

  private

  def geolocation
    if defined?(@geolocation)
      return @geolocation
    end

    @geolocation ||= GoogleMaps::Geolocation.new(latitude: params[:latitude],
                                                 longitude: params[:longitude])
  rescue ArgumentError
    @geolocation = nil
  end

  def payload
    permited = %i[
      address
      street_name
      number
      block_number
      latitude
      longitude
      last_contacted_at
    ]

    params.require(:location).permit(*permited)
  end

  def location
    @location ||= territory.locations.find(params[:id])
  end

  def show_territory
    redirect_to routes.territory_path(territory)
  end

  def territory
    @territory ||= current_account.territories.find(territory_id)
  end

  def territory_id
    keys = %i[
      territory_id
      apartment_building_territory_id
      regular_territory_id
      phone_list_territory_id
    ]
    params.slice(*keys).values.compact.first
  end
end