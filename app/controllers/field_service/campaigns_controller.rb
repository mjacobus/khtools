# frozen_string_literal: true

class FieldService::CampaignsController < ApplicationController
  def index
    @campaigns = Db::PreachingCampaign.order(created_at: :desc)
  end
end
