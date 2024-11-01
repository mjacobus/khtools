# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :require_authorization
  before_action :set_current
  helper_method :current_user

  layout :layout

  unless Rails.env.development?
    rescue_from Exception do |exception|
      ErrorHandler.new.notify_error(exception)
      @exception = exception
      render 'application/500', status: :internal_server_error
    end
  end

  rescue_from ActiveRecord::RecordNotFound, with: :render_page404

  rescue_from ActiveRecord::DeleteRestrictionError do |exception|
    if respond_to?(:show)
      flash.now[:error] = t('app.messages.cannot_delete_record')
      next show
    end

    raise exception
  end

  private

  def require_authorization
    if ControllerAcl.new(request).authorized?(current_user)
      return
    end

    if request.format.json?
      return render(json: { user_id: current_user&.id, error: t('app.messages.access_denied') },
                    status: :forbidden)
    end

    redirect_to('/', flash: { error: t('app.messages.access_denied') })
  end

  def set_current
    Current.user = current_user
    Current.root_url = root_url
  end

  def current_account
    @current_account ||= current_user.account
  end

  def current_user
    @current_user ||= UserSessionService.new(session:).current_user
  end

  def render_page404(_error)
    render 'application/404', status: :not_found
  end

  def paginate(scope)
    scope.page(params[:page]).per(params[:per_page])
  end

  def layout
    current_user ? 'application' : 'public'
  end

  def routes
    @routes ||= Routes.new
  end

  def export_pdf(file_name, options = {})
    default_options = {
      pdf: file_name,
      layout: 'pdf',
      header: {
        right: t('app.messages.page_x_of_y', x: '[page]', y: '[topage]'),
        font_size: 6
      }
    }

    render(default_options.merge(options))
  end
end
