# frozen_string_literal: true

module Territories
  class ParsedApartmentsComponent < ApplicationComponent
    has :apartments

    def render?
      apartments.any?
    end

    def grouped_apartments
      apartments.group_by { |value| value[0] }
    end
  end
end
