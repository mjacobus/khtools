# frozen_string_literal: true

class ConfigController < ApplicationController
  def index
    render json: {
      google_maps_static_api_key: ENV.fetch('GOOGLE_MAPS_STATIC_API_KEY', nil)
    }
  end
end
