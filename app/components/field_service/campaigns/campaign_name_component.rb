# frozen_string_literal: true

module FieldService
  module Campaigns
    class CampaignNameComponent < RecordAttributeComponent
      private

      def value
        record.name
      end

      def icon_name
        'reception-4'
      end
    end
  end
end
