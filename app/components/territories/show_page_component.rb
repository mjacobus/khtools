# frozen_string_literal: true

class Territories::ShowPageComponent < PageComponent
  include TerritoryAttributesConcern

  attr_reader :territory

  def initialize(territory:)
    @territory = territory

    breadcrumb.add_item(
      t("app.links.#{territory.type_key}_territories"),
      urls.territories_path(territory.type_key)
    )

    breadcrumb.add_item(territory.name)
  end
end
