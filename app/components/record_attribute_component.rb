# frozen_string_literal: true

class RecordAttributeComponent < ApplicationComponent
  def initialize(record, attribute_name:)
    @record = record
    @include_link = nil
    @include_icon = true
    @attribute_name = attribute_name
    @urls = Routes.new
  end

  def without_icon
    component.without_icon
    self
  end

  def include_icon?
    @include_icon
  end

  def with_link(link = nil)
    component.with_link(link || default_link)
    self
  end

  def with_label
    component.with_label(attribute_name(record, @attribute_name))
    self
  end

  def include_label?
    @include_label
  end

  def include_link?
    @include_link
  end

  def wrap_with(tag, options = {})
    component.wrap_with(tag, options)
    self
  end

  def call
    render(component) { value }
  end

  private

  attr_reader :record

  def component
    @component ||= AttributeComponent.new
      .with_icon(icon_name)
      .with_classes(bem)
  end

  def default_link
    attribute = record.send(@attribute_name)

    if attribute.present?
      return @urls.to(attribute)
    end

    '#'
  end

  # def options
  #   return {}
  #   {}.tap do |opts|
  #     if include_icon?
  #       opts[:icon_name] = icon_name
  #     end
  #     # opts[:label] = label
  #     opts[:classes] = bem
  #
  #     if @container_tag
  #       opts[:container_tag] = @container_tag
  #       opts[:container_options] = @container_options
  #     end
  #   end
  # end

  def to_date(date)
    l(date.to_date)
  end
end
