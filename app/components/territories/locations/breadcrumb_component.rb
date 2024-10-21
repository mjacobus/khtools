# frozen_string_literal: true

class Territories::Locations::BreadcrumbComponent < ApplicationComponent
  has :territory

  def call
    render breadcrumb
  end

  def on_index
    breadcrumb.add_item(t('app.attributes.locations'))
    self
  end

  def on_edit(_location)
    breadcrumb.add_item(t('app.attributes.locations'), urls.territory_locations_path(territory:))
    breadcrumb.add_item(t('app.links.edit'))
    self
  end

  def on_new
    breadcrumb.add_item(t('app.links.new_location'))
    self
  end

  private

  def breadcrumb
    @breadcrumb ||= BreadcrumbComponent.new.tap do |b|
      b.add_item(t('app.links.home'), urls.root_path, false)

      b.add_item(t('app.links.territories'))

      b.add_item(
        t("app.links.#{territory.type_key}_territories"),
        urls.territories_path(territory.type_key)
      )

      b.add_item(territory.name, urls.territory_path(territory))
    end
  end
end
