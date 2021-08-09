# frozen_string_literal: true

class AttributeWrapperComponent < ApplicationComponent
  def without_icon
    attribute.without_icon
    self
  end

  def with_link(link = nil)
    attribute.with_link(link || default_link)
    self
  end

  def with_label(*args)
    attribute.with_label(*args)
    self
  end

  def with_classes(*args)
    attribute.with_classes(*args)
    self
  end

  def wrap_with(tag, options = {})
    attribute.wrap_with(tag, options)
    self
  end

  def call
    render(attribute) { value }
  end

  private

  def default_link
    '#'
  end

  def attribute
    @attribute ||= AttributeComponent.new
      .with_icon(icon_name)
      .with_classes(bem)
  end
end
