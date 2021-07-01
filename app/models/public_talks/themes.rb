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
      number = number.to_i
      all.find { |theme| theme.number == number }
    end
  end
end
