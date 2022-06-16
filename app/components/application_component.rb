# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  MissingArgument = Class.new(StandardError)

  delegate :current_user, to: :helpers

  def self.has(field, public: false)
    define_method field do
      get(field) || raise(MissingArgument, "Missing argument: #{field}")
    end
    private field unless public
  end

  def attribute(value)
    AttributeWrapperComponent.new(value)
  end

  def initialize(options = {})
    @options = options
  end

  def icon(name, options = {}, &block)
    options[:class] = [options[:class], "bi bi-#{name}"].compact.join(' ')
    icon = tag.i('', **options)

    return icon unless block

    icon + '&nbsp;'.html_safe + yield
  end

  def bem(element = nil, modifier = nil, block: nil)
    block ||= self.class.to_s
    block = block.gsub('::', '_')

    parts = [block]

    parts << "__#{element}" if element

    parts << "--#{modifier}" if modifier

    parts.join
  end

  private

  def urls
    @urls ||= Routes.new
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
    klass = klass.class if klass.is_a?(ApplicationRecord)
    klass.human_attribute_name(attribute)
  end
end
