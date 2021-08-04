# frozen_string_literal: true

module FieldService
  module Campaigns
    class CampaignCodeComponent < RecordAttributeComponent
      private

      def value
        record.code
      end

      def icon_name
        'code'
      end
    end
  end
end
