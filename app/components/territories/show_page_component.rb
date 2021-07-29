# frozen_string_literal: true

class Territories::ShowPageComponent < PageComponent
  attr_reader :territory

  def initialize(territory:)
    @territory = territory

    breadcrumb.add_item(
      t("app.links.#{territory.type_key}_territories"),
      urls.territories_path(territory.type_key)
    )

    breadcrumb.add_item(territory.name)
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
end
