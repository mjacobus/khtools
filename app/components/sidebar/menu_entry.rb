# frozen_string_literal: true

module Sidebar
  class MenuEntry
    attr_reader :url, :text, :children, :icon

    def initialize(text, url, icon: nil)
      @text = text
      @url = url
      @children = []
      @icon = icon
    end

    def append_child(child)
      @children << child
    end

    def active?(url)
      if children.find { |child| child.active?(url) }
        return true
      end

      if url.include?(@url)
        return true
      end

      url_controller = Rails.application.routes.recognize_path(url)[:controller]
      controller = Rails.application.routes.recognize_path(@url)[:controller]
      url_controller == controller
    rescue ActionController::RoutingError
      false
    end
  end
end
