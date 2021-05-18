# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :require_authorization
  helper_method :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :render_page404

  private

  def require_authorization
    unless ControllerAcl.new(request).authorized?(current_user)
      redirect_to('/', flash: { error: t('app.messages.access_denied') })
    end
  end

  def current_user
    @current_user ||= UserSessionService.new(session: session).current_user
  end

  def render_page404(_error)
    render 'application/404', status: :not_found
  end
end
