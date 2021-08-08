# frozen_string_literal: true

module Congregation
  module Publishers
    class ShowPageComponent < PageComponent
      include PublisherAttributes

      has :publisher

      def actions
        [
          edit_link,
          destroy_link
        ]
      end

      private

      def setup_breadcrumb
        breadcrumb.add_item(t('app.links.publishers'), urls.publishers_path)
        breadcrumb.add_item(publisher.name)
      end
    end
  end
end
