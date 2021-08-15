# frozen_string_literal: true

module Territories
  class ParsedApartmentsComponent < ApplicationComponent
    has :apartments
    has :expected_number_of_apartments

    def render?
      apartments.any?
    end

    def grouped_apartments
      apartments.group_by { |value| group_by(value) }
    end

    def show_text?
      expected_number_of_apartments != apartments.size
    end

    def text
      t(
        'app.messages.x_out_of_z_apartments',
        expected: expected_number_of_apartments,
        registered: apartments.size
      )
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
