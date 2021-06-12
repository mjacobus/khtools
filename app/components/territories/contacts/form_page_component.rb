# frozen_string_literal: true

class Territories::Contacts::FormPageComponent < ApplicationComponent
  attr_reader :contact

  def initialize(territory:, contact:)
    @contact = contact
    @territory = territory
  end

  def page_title
    model_name(@contact)
  end

  def target_url
    if contact.id
      return edit_territories_commercial_territory_contact_path(@territory, contact)
    end

    territories_commercial_territory_contacts_path(@territory)
  end
end
