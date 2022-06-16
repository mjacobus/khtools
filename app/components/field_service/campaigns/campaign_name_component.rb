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
        return "(#{@code}) #{record.name}" if @code

        record.name
      end

      def icon_name
        'reception-4'
      end
    end
  end
end
