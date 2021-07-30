# frozen_string_literal: true

class Territories::AssignmentsController < ApplicationController
  def create
    territory.assign_to(params[:assignment][:publisher_id])
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
