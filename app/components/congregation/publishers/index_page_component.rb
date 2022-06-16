# frozen_string_literal: true

module Congregation
  module Publishers
    class IndexPageComponent < PageComponent
      has :publishers

      def new_link
        link_to(t('app.links.new'), urls.new_publisher_path)
      end

      private

      def setup_breadcrumb
        breadcrumb.add_item(t('app.links.publishers'))
      end

      def pagination
        PaginationComponent.new(publishers, position: :bottom)
      end
    end
  end
end
