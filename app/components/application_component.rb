# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  MissingArgument = Class.new(StandardError)

  def self.has(field, public: false)
    define_method field do
      get(field) || raise(MissingArgument, "Missing argument: #{field}")
    end
    unless public
      private field
    end
  end

  def initialize(options = {})
    @options = options
  end

  private

  def urls
    Rails.application.routes.url_helpers
  end

  def get(key)
    @options[key]
  end

  def t(key, **options)
    I18n.t(key, **options)
  end
end
