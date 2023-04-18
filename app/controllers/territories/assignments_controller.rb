# frozen_string_literal: true

class Territories::AssignmentsController < ApplicationController
  def index
    render Territories::Assignments::IndexPageComponent.new(
      territory: territory,
      assignments: territory.assignments
    )
  end

  def new
    @assignment ||= territory.assignments.build

    render Territories::Assignments::NewPageComponent.new(
      territory: territory,
      assignment: assignment
    )
  end

  def edit
    render Territories::Assignments::EditPageComponent.new(
      territory: territory,
      assignment: assignment
    )
  end

  def create
    payload = assignment_params
    territory.assign_to(
      payload[:assignee_id],
      campaign: payload[:campaign_id],
      notes: payload[:notes]
    )
    show_territory
  rescue ActiveRecord::RecordInvalid => exception
    @assignment = exception.record
    new
  end

  def update # rubocop:disable Mertrics/MethodLength
    payload = assignment_params
    dates = DateTimeParamParser.new.parse(payload)

    assignment_service.update_assignment(
      assignment: assignment,
      campaign: payload[:campaign_id],
      to: payload[:assignee_id],
      assigned_at: dates[:assigned_at],
      returned_at: dates[:returned_at],
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

    params.require(:assignment).permit(*permited)
  end

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
