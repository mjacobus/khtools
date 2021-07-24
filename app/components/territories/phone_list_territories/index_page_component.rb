# frozen_string_literal: true

class Territories::PhoneListTerritories::IndexPageComponent < Territories::RegularTerritories::IndexPageComponent
  private

  def model
    Db::PhoneListTerritory
  end

  def type
    :phone_list
  end

  def edit_action
    proc do |territory|
      link_to(t('app.links.edit'), edit_territories_phone_list_territory_path(territory), class: 'btn')
    end
  end

  def new_action
    link_to(t('app.links.new'), send("new_territories_#{type}_territory_path"), class: 'btn')
  end

  def delete_action
    proc do |territory|
      link_to(
        t('app.links.delete'),
        territories_phone_list_territory_path(territory),
        data: { method: :delete, confirm: t('app.messages.confirm_delete') },
        class: 'btn'
      )
    end
  end
end
