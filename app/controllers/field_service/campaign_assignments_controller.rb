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
end
