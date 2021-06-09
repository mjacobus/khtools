# frozen_string_literal: true

module Sidebar
  class MenuEntry
    attr_reader :url, :text, :active

    def initialize(text, url, active: false)
      @text = text
      @url = url
      @active = active
    end
  end
end
