# frozen_string_literal: true

class Territories::AssignmentsController < ApplicationController
  def create
    publisher_id = params[:assignment][:publisher_id]
    campaign_id = params[:assignment][:campaign_id]
    territory.assign_to(publisher_id, campaign_id: campaign_id)
    show_territory
  end

  def destroy
    territory.return
    show_territory
  end

  def new
    render Territories::Assignments::NewPageComponent.new(territory: territory)
  end

  private

  def show_territory
    redirect_to routes.territory_path(territory)
  end

  def territory
    @territory ||= Db::Territory.find(params[:territory_id])
  end
end
