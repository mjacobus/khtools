# frozen_string_literal: true

module FieldService
  module Campaigns
    class CampaignDatesComponent < RecordAttributeComponent
      private

      def value
        if dates.any?
          dates.map { |date| to_date(date) }.join(' - ')
        end
      end

      def dates
        @dates ||= [record.start_date, record.start_date]
      end

      def icon_name
        'calendar-date'
      end
    end
  end
end
