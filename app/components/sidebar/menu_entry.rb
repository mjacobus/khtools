# frozen_string_literal: true

module Sidebar
  class MenuEntry
    attr_reader :url, :text, :active, :children

    def initialize(text, url, active: false)
      @text = text
      @url = url
      @active = active
      @children = []
    end

    def append_child(child)
      @children << child
    end
  end
end
