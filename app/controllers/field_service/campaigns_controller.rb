# frozen_string_literal: true

class FieldService::CampaignsController < ApplicationController
  def index
    campaigns = paginate(model_class.order(created_at: :desc))
    render FieldService::Campaigns::IndexPageComponent.new(campaigns: campaigns)
  end

  def show
    render FieldService::Campaigns::ShowPageComponent.new(campaign: campaign)
  end

  def new
    @campaign = model_class.new
    render form(campaign)
  end

  def create
    @campaign = model_class.new
    save_record
  end

  def edit
    render form(campaign)
  end

  def update
    save_record
  end

  def destroy
    campaign.destroy
    redirect_to(action: :index)
  end

  private

  def campaign
    @campaign ||= model_class.find(params[:id])
  end

  def save_record
    campaign.attributes = attributes

    if campaign.save
      redirect_to action: :index
      return
    end

    render form(campaign), status: :unprocessable_entity
  end

  def form(campaign)
    FieldService::Campaigns::FormPageComponent.new(campaign: campaign)
  end

  def attributes
    params.require(:campaign).permit(
      :code,
      :description,
      :name,
      :start_date,
      :end_date
    )
  end

  def model_class
    Db::PreachingCampaign
  end
end
