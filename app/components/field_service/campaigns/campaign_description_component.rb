# frozen_string_literal: true

module FieldService
  module Campaigns
    class CampaignDescriptionComponent < RecordAttributeComponent
      private

      def value
        record.description
      end

      def icon_name
        'pencil'
      end
    end
  end
end
