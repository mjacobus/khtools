# frozen_string_literal: true

class Territories::ShowPageComponent < PageComponent
  include TerritoryAttributesConcern

  has :territory

  def actions
    [
      assignment_action,
      xls_action,
      edit_action,
      delete_action
    ].compact
  end

  def territory_attribute(name)
    attribute(name).with_label.without_icon
  end

  private

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.territories'))

    breadcrumb.add_item(
      t("app.links.#{territory.type_key}_territories"),
      urls.territories_path(territory.type_key)
    )

    breadcrumb.add_item(territory.name)
  end
end
