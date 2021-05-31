# frozen_string_literal: true

class FieldService::CampaignAssignmentsController < ApplicationController
  def index
    @campaign = Db::PreachingCampaign.find(params[:campaign_id])
    @assignments = @campaign.assignments.includes(:territory, :assignee)
  end

  # def show
  # end
  #
  # def new
  # end
  #
  # def create
  # end
  #
  # def edit
  # end
  #
  # def update
  # end
  #
  # def destroy
  # end
end
