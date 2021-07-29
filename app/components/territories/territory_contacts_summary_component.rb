# frozen_string_literal: true

module Territories
  class TerritoryContactsSummaryComponent < RecordAttributeComponent
    private

    def value
      if record.respond_to?(:contacts)
        I18n.t('app.messages.x_contacts', count: record.contacts.count)
      end
    end

    def icon_name
      'people'
    end
  end
end
