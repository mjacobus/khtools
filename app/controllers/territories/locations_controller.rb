# frozen_string_literal: true

class Territories::LocationsController < ApplicationController
  skip_before_action :require_authorization, if: -> { params[:token].present? }

  def index
    render Territories::Locations::IndexPageComponent.new(
      territory:,
      locations: territory.locations.by_block_number.by_friendly_address
    )
  end

  def new # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    if geolocation
      @location = territory.create_location_by_geolocation(geolocation)
      if session[:last_location_block]
        @location.update(block_number: session[:last_location_block])
      end
      return redirect_to(action: :edit, id: location.id)
    end

    @location = territory.locations.build(block_number: session[:last_location_block])
    render Territories::Locations::NewPageComponent.new(territory:, location:)
  rescue StandardError => exception
    ErrorHandler.new.notify_error(exception)
    flash.now[:error] = I18n.t('messages.could_not_automatically_create_location_error')
    @location = territory.locations.build
    render Territories::Locations::NewPageComponent.new(territory:, location:)
  end

  def edit
    render Territories::Locations::EditPageComponent.new(territory:, location:)
  end

  def create
    @location = territory.locations.build
    @location.update!(payload)
    redirect_to(action: :index)
  rescue ActiveRecord::RecordInvalid => exception
    @location = exception.record
    @location = territory.locations.build
    render Territories::Locations::NewPageComponent.new(territory:, location:)
  end

  def update
    @location = territory.locations.find(params[:id])
    @location.update!(payload)
    redirect_to(action: :index)
  rescue ActiveRecord::RecordInvalid => exception
    @location = exception.record
    @location = territory.locations.build
    render Territories::Locations::NewPageComponent.new(territory:, location:)
  end

  def destroy
    @location = territory.locations.find(params[:id])
    @location.destroy
    redirect_to(action: :index)
  end

  def mark_contacted
    @location = territory.locations.find(params[:id])
    @location.update(last_contacted_at: Time.current)
    redirect_to(action: :index)
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

  def payload # rubocop:disable Metrics/MethodLength
    permited = %i[
      address
      street_name
      number
      block_number
      latitude
      longitude
      notes
      last_contacted_at
      do_not_visit_at
    ]

    payload = params.require(:location).permit(*permited)

    if payload[:block_number]
      session[:last_location_block] = payload[:block_number]
    end

    payload
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
