# frozen_string_literal: true

class Territories::AssignmentsController < ApplicationController
  def index
    render Territories::Assignments::IndexPageComponent.new(
      territory: territory,
      assignments: territory.assignments
    )
  end

  def new
    render Territories::Assignments::NewPageComponent.new(territory: territory)
  end

  def create
    publisher_id = params[:assignment][:publisher_id]
    campaign_id = params[:assignment][:campaign_id]
    notes = params[:assignment][:notes]
    territory.assign_to(publisher_id, campaign: campaign_id, notes: notes)
    show_territory
  end

  def destroy
    territory.return
    show_territory
  end

  private

  def show_territory
    redirect_to routes.territory_path(territory)
  end

  def territory
    # TODO: scope to account
    @territory ||= Db::Territory.find(territory_id)
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
