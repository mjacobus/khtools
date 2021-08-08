# frozen_string_literal: true

module Territories
  class ContactEmailComponent < RecordAttributeComponent
    private

    def value
      record.email
    end

    def icon_name
      'envelope'
    end
  end
end
