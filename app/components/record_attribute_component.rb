# frozen_string_literal: true

class RecordAttributeComponent < ApplicationComponent
  def initialize(record, attribute_name:)
    @record = record
    @include_link = nil
    @include_icon = true
    @attribute_name = attribute_name
  end

  def without_icon
    @include_icon = false
    self
  end

  def include_icon?
    @include_icon
  end

  def with_link(link = nil)
    if link
      @link = link
    end

    @include_link = true
    self
  end

  def with_label
    if label
      @label = label
    end

    @include_label = true
    self
  end

  def label
    attribute_name(record, @attribute_name)
  end

  def include_label?
    @include_label
  end

  def include_link?
    @include_link
  end

  def link
    # NOOP
  end

  def call
    render AttributeComponent.new(**options) do
      value
    end
  end

  private

  attr_reader :record

  def options
    {}.tap do |opts|
      if include_icon?
        opts[:icon_name] = icon_name
      end
      opts[:label] = label
      opts[:classes] = bem
      if include_link?
        opts[:link] = link
      end

      if include_label?
        opts[:show_label] = include_label?
      end
    end
  end

  def to_date(date)
    l(date.to_date)
  end
end
