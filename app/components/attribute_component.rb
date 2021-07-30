# frozen_string_literal: true

class AttributeComponent < ApplicationComponent
  attr_reader :icon_name
  attr_reader :classes
  attr_reader :label
  attr_reader :link
  attr_reader :show_label

  def initialize(icon_name: nil, classes: nil, label: nil, link: nil, show_label: false)
    @icon_name = icon_name
    @classes = Array.wrap(classes)
    @label = label
    @link = link
    @show_label = show_label
  end

  def render?
    content.present?
  end

  def label_content
    if icon_name
      icon(icon_name) { label }
    else
      label
    end
  end

  def text_content
    if show_icon_in_text?
      return icon(icon_name, class: 'icon-soft') { content }
    end

    content
  end

  private

  def show_icon_in_text?
    icon_name && !label
  end
end
