# frozen_string_literal: true

class VersionController < ApplicationController
  skip_before_action :require_authorization

  def show
    render(json: { version: ENV.fetch('KAMAL_VERSION', 'unknown'), environment: Rails.env })
  end
end
