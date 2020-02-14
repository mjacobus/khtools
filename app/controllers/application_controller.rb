# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :require_enabled_user
  helper_method :current_user

  private

  def require_enabled_user
    unless current_user
      redirect_to '/'
    end
  end

  def current_user
    @current_user ||= UserSessionService.new(session: session).current_user
  end
end
