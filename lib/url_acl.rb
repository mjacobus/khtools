# frozen_string_literal: true

class UrlAcl
  SimplifiedRequest = Struct.new(:params)

  def initialize(url)
    @url = url
  end

  def authorized?(user)
    params = Rails.application.routes.recognize_path(@url.to_s)
    ControllerAcl.new(SimplifiedRequest.new(params)).authorized?(user)
  end
end
