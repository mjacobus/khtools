# frozen_string_literal: true

class AttributeComponent < ApplicationComponent
  attr_reader :icon_name
  attr_reader :classes
  attr_reader :label
  attr_reader :link
  attr_reader :show_label
  attr_reader :container_tag
  attr_reader :container_options

  def initialize(icon_name: nil, classes: nil, label: nil, link: nil, show_label: false, container_tag: :span, container_options: {})
    @icon_name = icon_name
    @classes = Array.wrap(classes)
    @label = label
    @link = link
    @show_label = show_label
    @container_tag = :span
    @container_options = { class: class_names(bem, classes), label: label, title: label }
    wrap_with(container_tag, container_options)
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

  def with_classes(classes)
    @classes += Array.wrap(classes)
    self
  end

  def with_label(label = nil)
    @show_label = true
    @label ||= label
    self
  end

  def without_label
    @show_label = false
    self
  end

  def with_icon(icon)
    @icon_name = icon
    self
  end

  def without_icon
    @icon_name = nil
    self
  end

  def with_link(link)
    @link = link
    self
  end

  def text_content
    if show_icon_in_text?
      return icon(icon_name, class: 'icon-soft') { content }
    end

    content
  end

  def wrap_with(tag, options = {})
    @container_tag = tag
    classes = [@container_options[:class], options[:class]].compact
    @container_options.merge!(options)[:class] = class_names(classes)
    self
  end

  private

  def show_icon_in_text?
    icon_name && !label
  end
end
