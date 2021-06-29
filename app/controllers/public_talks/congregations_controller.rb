# frozen_string_literal: true

class PublicTalks::CongregationsController < ApplicationController
  def index
    congregations = Db::Congregation.all
    render Congregations::IndexPageComponent.new(congregations)
  end
end
