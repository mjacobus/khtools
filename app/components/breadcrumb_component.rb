# frozen_string_literal: true

class BreadcrumbComponent < ApplicationComponent
  attr_reader :items

  Item = Struct.new(:text, :url, :header_title?)

  def initialize
    @items = []
  end

  def render?
    items.any?
  end

  # rubocop:disable Style/OptionalBooleanParameter
  def add_item(text, url = nil, append_title_part = true)
    @items << Item.new(text, url, append_title_part)
  end
  # rubocop:enable Style/OptionalBooleanParameter

  def active_class_for_index(index)
    'active' if (index + 1) == items.length
  end

  def aria_current(index)
    'aria-current="page"' if (index + 1) == items.length
  end

  def page_title
    @items.select(&:header_title?).reverse.map(&:text).join(' · ')
  end
end
