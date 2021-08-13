# frozen_string_literal: true

module Territories
  class TerritoryAssignmentDatesComponent < RecordAttributeComponent
    private

    def value
      dates.compact.map { |date| l(date) }.join(' - ')
    end

    def dates
      if defined?(@dates)
        return @dates
      end

      @dates = [record.assigned_at&.to_date]

      if record.respond_to?(:returned_at)
        @dates.push(record.returned_at&.to_date)
      end

      @dates
    end

    def icon_name
      'calendar-date'
    end
  end
end
