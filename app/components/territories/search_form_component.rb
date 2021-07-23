# frozen_string_literal: true

class Territories::SearchFormComponent < ApplicationComponent
  def initialize(type:, params:)
    @type = type
    @params = params
  end

  def action
    url_for
  end

  def phone_providers
    Db::PhoneProvider.pluck(:name, :id)
  end

  def publishers
    Db::Publisher.pluck(:name, :id)
  end

  def type
    ActiveSupport::StringInquirer.new(@type.to_s)
  end
end
