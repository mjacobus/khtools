# frozen_string_literal: true

class Territories::CommercialTerritories::IndexPageComponent < Territories::RegularTerritories::IndexPageComponent
  private

  def model
    Db::ApartmentBuildingTerritory
  end

  def type
    :apartment_building
  end

  def territory_actions
    [contacts_action, new_contact_action, super].flatten
  end

  def contacts_action
    proc do |territory|
      link_to t('app.links.contacts'), territories_commercial_territory_contacts_path(territory), class: 'btn'
    end
  end

  def new_contact_action
    proc do |territory|
      link_to t('app.links.new_contact'), new_territories_commercial_territory_contact_path(territory), class: 'btn'
    end
  end
end
