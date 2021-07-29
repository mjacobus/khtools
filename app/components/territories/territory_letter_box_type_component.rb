# frozen_string_literal: true

module Territories
  class TerritoryLetterBoxTypeComponent < RecordAttributeComponent
    private

    def value
      record.letter_box_type&.name
    end

    def icon_name
      'mailbox2'
    end
  end
end
