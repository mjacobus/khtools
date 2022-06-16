# frozen_string_literal: true

class OauthConfig
  attr_reader :provider, :uid, :name, :email, :avatar

  def initialize(attributes)
    @provider = attributes.fetch(:provider)
    @uid = attributes.fetch(:uid)
    @name = attributes.fetch(:name)
    @email = attributes.fetch(:email)
    @avatar = attributes.fetch(:avatar)
  end
end
