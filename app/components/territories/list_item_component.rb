# frozen_string_literal: true

class Territories::ListItemComponent < ApplicationComponent
  include TerritoryAttributesConcern

  attr_reader :territory

  def initialize(territory)
    @territory = territory
  end

  def territory_actions
    [
      xls_action,
      contacts_action,
      new_contact_action,
      show_action,
      edit_action,
      delete_action
    ]
  end
end
