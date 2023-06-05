# frozen_string_literal: true

module Territories
  class TerritoryLastAssignmentDatesComponent < RecordAttributeComponent
    private

    def value
      parts = [dates.map { |date| l(date.to_date) }.join(' - ')]
      parts.push(time_ago)
      parts.join(' ')
    end

    def dates
      if defined?(@dates)
        return @dates
      end

      @dates = []

      unless assignment
        return []
      end

      @dates.push(assignment.assigned_at)
      @dates.push(assignment.returned_at)
      @dates.compact!
      @dates
    end

    def assignment
      if defined?(@assignment)
        return @assignment
      end

      @assignment ||= record.last_assignment
    end

    def time_ago
      if dates.any?
        text = time_ago_in_words(dates.last)
        "(#{text} atrás)#{campaign_info}"
      end
    end

    def campaign_info
      if assignment.campaign
        " - #{assignment.campaign.name}"
      end
    end

    def icon_name
      'calendar-date'
    end
  end
end
