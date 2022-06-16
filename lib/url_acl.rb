# frozen_string_literal: true

class UrlAcl
  SimplifiedRequest = Struct.new(:params)

  PUBLIC_URLS = [
    '/logout'
  ].freeze

  def initialize(url)
    @url = url
  end

  def authorized?(user)
    return true if PUBLIC_URLS.include?(@url)

    params = Rails.application.routes.recognize_path(@url.to_s)
    ControllerAcl.new(SimplifiedRequest.new(params)).authorized?(user)
  end
end
