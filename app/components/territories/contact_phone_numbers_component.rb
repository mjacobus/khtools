# frozen_string_literal: true

module Territories
  class ContactPhoneNumbersComponent < RecordAttributeComponent
    private

    def value
      if phone_numbers.any?
        phone_numbers.map do |number|
          PhoneNumber.new(number)
        end.join(' / ')
      end
    end

    def phone_numbers
      @phone_numbers ||= [record.phone, record.phone2].map(&:presence).compact
    end

    def icon_name
      'envelope'
    end
  end
end
