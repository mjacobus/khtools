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

    def visible?(user)
      if children.any?
        return children.any? { |child| child.visible?(user) }
      end

      UrlAcl.new(url).authorized?(user)
    end

    def active?(url)
      if children.any?
        return children.any? { |child| child.active?(url) }
      end

      current = Rails.application.routes.recognize_path(url)
      own = Rails.application.routes.recognize_path(@url)

      # Same controller and, for entries like /finance/integrations/telegram, same params.
      if own.except(:action) <= current
        return true
      end

      own[:controller] != 'home' && url.include?(@url)
    rescue ActionController::RoutingError
      false
    end
  end
end
