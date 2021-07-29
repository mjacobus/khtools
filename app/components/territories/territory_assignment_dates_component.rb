# frozen_string_literal: true

module Territories
  class TerritoryAssignmentDatesComponent < RecordAttributeComponent
    private

    def value
      dates.map { |date| l(date) }.join(' - ')
    end

    def dates
      @dates = [record.assigned_at&.to_date, record.returned_at&.to_date].compact
    end

    def icon_name
      'calendar-date'
    end
  end
end
