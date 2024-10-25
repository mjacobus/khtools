# frozen_string_literal: true

# frozen_string

class Territories::Locations::IndexPageComponent < PageComponent
  has :territory
  has :locations

  def actions(location)
    [
      contacted_action(location),
      edit_action(location),
      delete_action(location)
    ]
  end

  def locations_by_block
    locations.group_by(&:block_number)
  end

  def breadcrumb
    @breadcrumb ||= Territories::Locations::BreadcrumbComponent.new(territory:)
  end

  def edit_action(location)
    link_to(t('app.links.edit'), urls.edit_territory_location_path(location), class: 'btn')
  end

  def contacted_action(location)
    # TODO: Hotwire it
    link_to(
      t('app.links.log_contact'),
      urls.mark_territory_location_as_contacted_path(location),
      data: { method: :post, confirm: t('app.messages.confirm_contacted') },
      class: 'btn'
    )
  end

  def delete_action(location)
    link_to(
      t('app.links.delete'),
      urls.territory_location_path(location),
      data: { method: :delete, confirm: t('app.messages.confirm_delete') },
      class: 'btn'
    )
  end

  def block_description(block)
    block = block.presence || '?'
    "Quadra #{block}"
  end
end
