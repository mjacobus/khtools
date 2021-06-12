# frozen_string_literal: true

class DropdownMenuComponent < ApplicationComponent
  renders_many :items
  attr_reader :title

  def initialize(title)
    @title = title
  end
end
