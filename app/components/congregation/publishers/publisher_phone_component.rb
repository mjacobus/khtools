# frozen_string_literal: true

module Congregation
  module Publishers
    class PublisherPhoneComponent < RecordAttributeComponent
      private

      def value
        if record.phone.present?
          PhoneNumber.new(record.phone).to_s
        end
      end

      def icon_name
        'phone'
      end
    end
  end
end
