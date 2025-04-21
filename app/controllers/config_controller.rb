# frozen_string_literal: true

class ConfigController < ApplicationController
  def index
    render json: {
      google_maps_static_api_key: Rails.application.secrets.dig(:google_maps, :static_api_key)
    }
  end
end
