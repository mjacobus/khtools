# frozen_string_literal: true

module FieldService
  module Campaigns
    class ListItemComponent < ApplicationComponent
      include FieldServiceCampaignConcern

      has :campaign

      def actions
        [
          assignments_action,
          edit_action,
          show_action,
          delete_action
        ]
      end
    end
  end
end
