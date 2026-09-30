# frozen_string_literal: true

module Congregation
  module Publishers
    class PublisherEmailComponent < RecordAttributeComponent
      private

      def value
        record.email
      end

      def icon_name
        'at'
      end
    end
  end
end
