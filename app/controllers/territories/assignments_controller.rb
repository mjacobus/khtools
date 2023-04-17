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

  def edit
    render Territories::Assignments::EditPageComponent.new(
      territory: territory,
      assignment: assignment
    )
  end

  def create
    assignee_id = params[:assignment][:assignee_id]
    campaign_id = params[:assignment][:campaign_id]
    notes = params[:assignment][:notes]
    territory.assign_to(assignee_id, campaign: campaign_id, notes: notes)
    show_territory
  end

  def destroy
    territory.return
    show_territory
  end

  private

  def assignment
    @assignment ||= territory.assignments.find(params[:id])
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
