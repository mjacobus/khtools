# frozen_string_literal: true

module Congregation
  module Publishers
    class PublisherGroupComponent < RecordAttributeComponent
      private

      def value
        record.group&.name
      end

      def icon_name
        'people'
      end
    end
  end
end
