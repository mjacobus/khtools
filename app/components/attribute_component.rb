# frozen_string_literal: true

class AttributeComponent < ApplicationComponent
  attr_reader :icon_name
  attr_reader :classes

  def initialize(icon_name: nil, classes: nil)
    @icon_name = icon_name
    @classes = Array.wrap(classes)
  end

  def render?
    content.present?
  end
end
