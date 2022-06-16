# frozen_string_literal: true

module FieldService
  module Campaigns
    class FormPageComponent < PageComponent
      has :campaign

      def target_url
        return urls.field_service_campaign_path(campaign) if campaign.id

        urls.field_service_campaigns_path
      end

      private

      def setup_breadcrumb
        breadcrumb.add_item(t('app.links.preaching_campaigns'), urls.public_talks_speakers_path)

        if campaign.id
          breadcrumb.add_item(
            campaign.name,
            urls.public_talks_speaker_path(campaign)
          )
          breadcrumb.add_item(t('app.links.edit'))
          return
        end

        breadcrumb.add_item(t('app.links.new'))
      end
    end
  end
end
