# frozen_string_literal: true

class PaginationComponent < ApplicationComponent
  attr_reader :items
  attr_reader :position

  def initialize(items, position: :bottom)
    @items = items
    @position = position
  end

  def top?
    @position == :top
  end

  def bottom?
    @position == :bottom
  end
end
