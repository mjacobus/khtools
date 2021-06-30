# frozen_string_literal: true

class PublicTalks::CongregationsController < ApplicationController
  def index
    congregations = Db::Congregation.all
    render Congregations::IndexPageComponent.new(congregations)
  end

  def edit
    congregation = Db::Congregation.find(params[:id])
    render Congregations::FormPageComponent.new(congregation)
  end
end
