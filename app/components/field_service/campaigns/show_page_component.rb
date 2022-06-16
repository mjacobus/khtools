# frozen_string_literal: true

module FieldService
  module Campaigns
    class ShowPageComponent < PageComponent
      include FieldServiceCampaignConcern

      has :campaign

      def actions
        [
          assignments_action,
          edit_action,
          delete_action
        ]
      end

      private

      def setup_breadcrumb
        breadcrumb.add_item(
          t('app.links.preaching_campaigns'),
          urls.field_service_campaigns_path
        )

        breadcrumb.add_item(campaign.name)
      end
    end
  end
end
