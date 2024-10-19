# frozen_string_literal: true

class Territories::LocationsController < ApplicationController
  def index
    render Territories::Locations::IndexPageComponent.new(
      territory:,
      locations: territory.locations
    )
  end

  def new
    @location ||= territory.locations.build

    render Territories::Locations::NewPageComponent.new(territory:, location:)
  end

  def edit
    render Territories::Locations::EditPageComponent.new(territory:, location:)
  end

  def create
  rescue ActiveRecord::RecordInvalid => exception
    @location = exception.record
    new
  end

  def update # rubocop:disable Metrics/MethodLength
    payload = assignment_params

    assignment_service.update_assignment(
      location:,
      campaign: payload[:campaign_id],
      to: payload[:assignee_id],
      assigned_at: payload[:assigned_at],
      returned_at: payload[:returned_at],
      notes: payload[:notes]
    )
    show_territory
  rescue ActiveRecord::RecordInvalid
    edit
  end

  def destroy
    territory.return
    show_territory
  end

  private

  def assignment_service
    @assignment_service ||= TerritoryAssignmentService.new
  end

  def assignment_params
    permited = %i[assignee_id campaign_id notes]

    if params[:action] == 'update'
      permited += %i[assigned_at returned_at]
    end

    params.require(:location).permit(*permited)
  end

  def location
    @location ||= territory.assignments.find(params[:id])
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
