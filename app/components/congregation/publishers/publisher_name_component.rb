# frozen_string_literal: true

module Congregation
  module Publishers
    class PublisherNameComponent < RecordAttributeComponent
      private

      def value
        record.name
      end

      def icon_name
        'person'
      end
    end
  end
end
