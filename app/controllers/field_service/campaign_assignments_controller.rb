# frozen_string_literal: true

class FieldService::CampaignAssignmentsController < ApplicationController
  def index
    @campaign = Db::PreachingCampaign.find(params[:campaign_id])
  end

  def edit
    # TODO
  end

  def update
    # TODO
  end

  def create_assignments
    service = FieldService::CampaignAssignmentService.new
    service.create(campaign_id: params[:campaign_id], territory_type: params[:territory_type])
    redirect_to field_service_campaign_assignments_url(params[:campaign_id])
  end
end
