# frozen_string_literal: true

module FieldService
  module Campaigns
    class CampaignDatesComponent < RecordAttributeComponent
      private

      def value
        dates.map { |date| to_date(date) }.join(' - ') if dates.any?
      end

      def dates
        @dates ||= [record.start_date, record.end_date].compact
      end

      def icon_name
        'calendar-date'
      end
    end
  end
end
