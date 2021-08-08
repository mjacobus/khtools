# frozen_string_literal: true

module Congregation
  module Publishers
    class ListItemComponent < ApplicationComponent
      include PublisherAttributes

      has :publisher

      def actions
        [
          show_link,
          edit_link,
          destroy_link
        ]
      end
    end
  end
end
