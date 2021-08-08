# frozen_string_literal: true

module Territories
  class ContactNameComponent < RecordAttributeComponent
    private

    def value
      record.name
    end

    def icon_name
      'shop'
    end
  end
end
