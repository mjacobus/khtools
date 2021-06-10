# frozen_string_literal: true

module Sidebar
  class MenuEntry
    attr_reader :url, :text, :active, :children, :icon

    def initialize(text, url, active: false, icon: nil)
      @text = text
      @url = url
      @active = active
      @children = []
      @icon = icon
    end

    def append_child(child)
      @children << child
    end
  end
end
