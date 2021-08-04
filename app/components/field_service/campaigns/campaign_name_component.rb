# frozen_string_literal: true

module FieldService
  module Campaigns
    class CampaignNameComponent < RecordAttributeComponent
      def with_code
        @code = record.code
        self
      end

      private

      def value
        if @code
          return "(#{@code}) #{record.name}"
        end

        record.name
      end

      def icon_name
        'reception-4'
      end
    end
  end
end
