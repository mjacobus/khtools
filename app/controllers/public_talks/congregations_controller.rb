# frozen_string_literal: true

class PublicTalks::CongregationsController < ApplicationController
  def index
    congregations = paginate(Db::Congregation.all.order(:name))
    render Congregations::IndexPageComponent.new(congregations)
  end

  def show
    congregation = Db::Congregation.find(params[:id])
    render Congregations::ShowPageComponent.new(congregation)
  end

  def new
    congregation = Db::Congregation.new
    render Congregations::FormPageComponent.new(congregation)
  end

  def create
    congregation = Db::Congregation.new(congregation_params)

    if congregation.save
      return redirect_to(action: :index)
    end

    render Congregations::FormPageComponent.new(congregation), status: :unprocessable_entity
  end

  def edit
    congregation = Db::Congregation.find(params[:id])
    render Congregations::FormPageComponent.new(congregation)
  end

  def update
    congregation = Db::Congregation.find(params[:id])

    if congregation.update(congregation_params)
      return redirect_to(action: :index)
    end

    render Congregations::FormPageComponent.new(congregation), status: :unprocessable_entity
  end

  def destroy
    congregation = Db::Congregation.find(params[:id])
    congregation.destroy
    redirect_to(action: :index)
  end

  private

  def congregation_params
    params.require(:congregation).permit(
      :name,
      :address,
      :primary_contact_person,
      :primary_contact_phone,
      :primary_contact_email,
      :weekend_meeting_time,
      :local
    )
  end
end
