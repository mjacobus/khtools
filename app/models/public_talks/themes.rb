# frozen_string_literal: true

module PublicTalks
  class Themes
    def initialize
      @themes = 1.upto(194).map do |num|
        Theme.new(num)
      end
    end

    def all
      @themes
    end

    def find(number)
      all.find { |theme| theme.number == number.to_i } || SpecialTheme.new(number)
    end
  end
end
