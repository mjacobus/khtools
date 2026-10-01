# frozen_string_literal: true

module Congregation
  module Publishers
    class PublisherUserComponent < RecordAttributeComponent
      private

      def value
        record.user&.email
      end

      def icon_name
        'person-badge'
      end
    end
  end
end
