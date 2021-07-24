# frozen_string_literal: true

class Territories::CommercialTerritories::IndexPageComponent < Territories::RegularTerritories::IndexPageComponent
  private

  def model
    Db::ApartmentBuildingTerritory
  end

  def type
    :commercial
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

  def edit_action
    proc do |territory|
      link_to(t('app.links.edit'), send("edit_territories_#{type}_territory_path", territory), class: 'btn')
    end
  end

  def new_action
    link_to(t('app.links.new'), send("new_territories_#{type}_territory_path"), class: 'btn')
  end

  def delete_action
    proc do |territory|
      link_to(
        t('app.links.delete'),
        send("territories_#{type}_territory_path", territory),
        data: { method: :delete, confirm: t('app.messages.confirm_delete') },
        class: 'btn'
      )
    end
  end
end
