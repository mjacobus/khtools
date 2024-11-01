class ErrorHandler
  def notify_error(exception)
    Rails.logger.error(exception)

    if send_notification?
      Sentry.capture_exception(exception)
    end
  end

  private

  def send_notification?
    if Rails.env.development?
      return false
    end

    if Rails.env.test?
      return false
    end

    true
  end
end
