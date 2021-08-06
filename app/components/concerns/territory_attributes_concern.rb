# frozen_string_literal: true

module TerritoryAttributesConcern
  delegate :contacts_text, to: :helper
  delegate :assign_action, to: :helper
  delegate :assignment_action, to: :helper
  delegate :contacts_action, to: :helper
  delegate :delete_action, to: :helper
  delegate :edit_action, to: :helper
  delegate :new_contact_action, to: :helper
  delegate :show_action, to: :helper
  delegate :type, to: :helper
  delegate :unassign_action, to: :helper
  delegate :xls_action, to: :helper

  def helper
    @helper ||= TerritoryHelper.new(territory, self)
  end

  def attribute(name)
    helper.attribute_component(name)
  end
end
