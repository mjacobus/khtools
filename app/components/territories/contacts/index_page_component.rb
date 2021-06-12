# frozen_string_literal: true

class Territories::Contacts::IndexPageComponent < ApplicationComponent
  attr_reader :territory
  attr_reader :contacts

  def initialize(territory:)
    @territory = territory
    @contacts = territory.contacts
  end

  def title
    model_name(Db::Contact)
  end

  def edit_path(contact)
    edit_territories_commercial_territory_contact_path(territory, contact)
  end

  def contact_path(contact)
    territories_commercial_territory_contact_path(territory, contact)
  end

  def phones(contact)
    [contact.phone, contact.phone2].map(&:presence).compact.map do |phone|
      PhoneNumber.new(phone)
    end
  end
end
