# frozen_string_literal: true

module FieldService
  module Campaigns
    class IndexPageComponent < PageComponent
      has :campaigns

      def new_link
        link_to(t('app.links.new'), urls.new_field_service_campaign_path)
      end

      def pagination
        PaginationComponent.new(campaigns, position: :bottom)
      end

      private

      def setup_breadcrumb
        breadcrumb.add_item(t('app.links.preaching_campaigns'))
      end
    end
  end
end
