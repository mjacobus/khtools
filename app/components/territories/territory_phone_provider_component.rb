# frozen_string_literal: true

module Territories
  class TerritoryPhoneProviderComponent < RecordAttributeComponent
    private

    def value
      if record.respond_to?(:phone_provider)
        record.phone_provider&.name
      end
    end

    def icon_name
      'phone'
    end
  end
end
