# frozen_string_literal: true

class FieldService::CampaignAssignmentsController < ApplicationController
  def index
    assignments = paginate(campaign.assignments.with_dependencies)
    render FieldService::Campaigns::Assignments::IndexPageComponent.new(
      campaign:,
      assignments:
    )
  end

  def edit
    @assignment = campaign.assignments.find(params[:id])
  end

  def update
    @assignment = campaign.assignments.find(params[:id])

    if @assignment.update(attributes)
      return redirect_to field_service_campaign_assignments_url(@campaign)
    end

    render :edit
  end

  private

  def attributes
    params.require(:assignment)
      .permit(:assignee_id, :assigned_at, :returned_at)
  end

  def campaign
    @campaign ||= Db::PreachingCampaign.find(params[:campaign_id])
  end
end
