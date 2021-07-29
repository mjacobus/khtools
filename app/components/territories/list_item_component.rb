# frozen_string_literal: true

class Territories::ListItemComponent < PageComponent
  attr_reader :territory

  def initialize(territory)
    @territory = territory
  end

  def territory_icon
    {
      phone_list: :phone,
      commercial: :cart4,
      regular: :map,
      apartment_building: :building
    }.fetch(territory.type_key.to_sym)
  end

  def contacts_text(territory)
    I18n.t('app.messages.x_contacts', count: territory.contacts.count)
  end

  def attribute_name(territory, attribute)
    territory.class.human_attribute_name(attribute)
  end

  def actions
    [edit_action, contacts_action, new_contact_action, show_action, delete_action]
  end

  private

  def contacts_action
    if type == :commercial
      link_to t('app.links.contacts'), territories_commercial_territory_contacts_path(territory), class: 'btn'
    end
  end

  def new_contact_action
    if type == :commercial
      link_to t('app.links.new_contact'), new_territories_commercial_territory_contact_path(territory), class: 'btn'
    end
  end

  def edit_action
    link_to(t('app.links.edit'), send("edit_territories_#{type}_territory_path", territory), class: 'btn')
  end

  def show_action
    link_to(
      t('app.links.view'),
      urls.territory_path(territory),
      class: 'btn'
    )
  end

  def delete_action
    link_to(
      t('app.links.delete'),
      urls.territory_path(territory),
      data: { method: :delete, confirm: t('app.messages.confirm_delete') },
      class: 'btn'
    )
  end

  def type
    territory.type_key.to_sym
  end
end
