# frozen_string_literal: true

module Territories
  class ParsedApartmentsComponent < ApplicationComponent
    has :apartments

    def render?
      apartments.any?
    end

    def grouped_apartments
      apartments.group_by { |value| group_by(value) }
    end

    private

    def group_by(value)
      @difference ||= (apartments.last.length - apartments.first.length)
      value[(0..@difference)]
    rescue StandardError
      value[0].to_s
    end
  end
end
