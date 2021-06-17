# frozen_string_literal: true

class DropdownMenuComponent < ApplicationComponent
  renders_many :items
  attr_reader :title
  attr_reader :icon

  def initialize(title: '', classes: [], icon: 'three-dots', pull: nil)
    @title = title
    @classes = Array.wrap(classes)
    @icon = icon
    @pull = pull
  end

  def classes
    @classes.join(' ')
  end

  def container_classes
    if @pull
      "pull-#{@pull}"
    end
  end
end
