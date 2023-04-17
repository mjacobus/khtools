# frozen_string_literal: true

class Territories::AssignmentsController < ApplicationController
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
    @territory ||= Db::Territory.find(params[:territory_id])
  end
end
