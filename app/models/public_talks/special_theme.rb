# frozen_string_literal: true

module PublicTalks
  class SpecialTheme
    attr_reader :theme

    def initialize(theme)
      @theme = theme
    end

    def to_s
      @theme
    end
  end
end
