# frozen_string_literal: true

class PaginationComponent < ApplicationComponent
  attr_reader :items

  def initialize(items)
    @items = items
  end
end
