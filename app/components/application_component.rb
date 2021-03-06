# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  MissingArgument = Class.new(StandardError)

  delegate :current_user, to: :helpers

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

  def icon(name, options = {}, &block)
    options[:class] = [options[:class], "bi bi-#{name}"].compact.join(' ')
    icon = tag.i('', **options)

    unless block
      return icon
    end

    icon + '&nbsp;'.html_safe + yield
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

  def model_name(model_or_model_class)
    model_or_model_class.model_name.human
  end

  def attribute_name(klass, attribute)
    klass.human_attribute_name(attribute)
  end
end
