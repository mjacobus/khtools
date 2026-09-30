# frozen_string_literal: true

module Congregation
  module Publishers
    class PublisherEmergencyContactComponent < RecordAttributeComponent
      private

      def value
        [name, phone_number].filter_map(&:presence).join(' - ')
      end

      def name
        record.send(:"#{@attribute_name}_name")
      end

      def phone_number
        number = record.send(:"#{@attribute_name}_phone_number")

        if number.present?
          PhoneNumber.new(number).to_s
        end
      end

      def icon_name
        'telephone-plus'
      end
    end
  end
end
