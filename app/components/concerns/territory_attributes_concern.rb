# frozen_string_literal: true

module TerritoryAttributesConcern
  def attribute(name)
    "Territories::Territory#{name.to_s.classify}Component".constantize.new(territory, attribute_name: name)
  rescue NameError => _exception
    "Territories::Territory#{name.to_s.classify.pluralize}Component".constantize.new(territory, attribute_name: name)
  end

  def contacts_text(territory)
    I18n.t('app.messages.x_contacts', count: territory.contacts.count)
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

  def xls_action
    if type == :phone_list
      link_to(
        t('app.links.download_xls'),
        urls.territory_download_xls_path(territory),
        class: 'btn'
      )
    end
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
