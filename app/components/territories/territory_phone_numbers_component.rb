# frozen_string_literal: true

module Territories
  class TerritoryPhoneNumbersComponent < RecordAttributeComponent
    private

    def value
      if phone_numbers.any?
        phone_numbers.join('- ')
      end
    end

    def phone_numbers
      @phone_numbers ||= [
        record.initial_phone_number,
        record.final_phone_number
      ].compact.map { |num| PhoneNumber.new(num) }
    end

    def icon_name
      'telephone'
    end
  end
end
