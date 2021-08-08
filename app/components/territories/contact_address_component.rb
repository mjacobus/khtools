# frozen_string_literal: true

module Territories
  class ContactAddressComponent < RecordAttributeComponent
    private

    def value
      record.address
    end

    def icon_name
      'map'
    end
  end
end
