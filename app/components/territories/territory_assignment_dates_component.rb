# frozen_string_literal: true

module Territories
  class TerritoryAssignmentDatesComponent < RecordAttributeComponent
    private

    def value
      dates.compact.map { |date| l(date) }.join(' - ')
    end

    def dates
      return @dates if defined?(@dates)

      @dates = [record.assigned_at&.to_date]

      @dates.push(record.returned_at&.to_date) if record.respond_to?(:returned_at)

      @dates
    end

    def icon_name
      'calendar-date'
    end
  end
end
