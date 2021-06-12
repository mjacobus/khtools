# frozen_string_literal: true

class DropdownMenuComponent < ApplicationComponent
  renders_many :items
  attr_reader :title

  def initialize(title: '', classes: [])
    @title = title
    @classes = Array.wrap(classes)
  end

  def classes
    @classes.join(' ')
  end
end
