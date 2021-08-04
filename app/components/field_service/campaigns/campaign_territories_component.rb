# frozen_string_literal: true

module FieldService
  module Campaigns
    class CampaignTerritoriesComponent < RecordAttributeComponent
      private

      def value
        record.assignments.count.to_s
      end

      def icon_name
        'people'
      end
    end
  end
end
