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

  def territory_actions
    [
      xls_action,
      edit_action,
      delete_action
    ].compact
  end

  def territory_attribute(name)
    attribute(name).with_label.without_icon
  end

  def attributes
    %i[
      name
      building_name
      address
      area
      number_of_apartments
      has_a_roof

      intercom_type
      letter_box_type
      preaching_methods
      phone_numbers
      territory
      phone_provider
      apartments
      notes
      contacts_summary
      assignee
      assignment_dates
    ]
  end
end
