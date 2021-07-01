# frozen_string_literal: true

module PublicTalks
  class Theme
    attr_reader :number

    def initialize(number)
      @number = number.to_i
    end

    def theme
      I18n.t("app.public_talks.themes.theme_#{number}")
    end

    def to_s
      "#{number} - #{theme}"
    end
  end
end
