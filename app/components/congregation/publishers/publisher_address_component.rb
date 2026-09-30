# frozen_string_literal: true

module Congregation
  module Publishers
    class PublisherAddressComponent < RecordAttributeComponent
      private

      def value
        record.address
      end

      def icon_name
        'map'
      end
    end
  end
end
