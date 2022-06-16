# frozen_string_literal: true

module Territories
  class TerritoryPhoneProviderComponent < RecordAttributeComponent
    private

    def value
      record.phone_provider&.name if record.respond_to?(:phone_provider)
    end

    def icon_name
      'phone'
    end
  end
end
