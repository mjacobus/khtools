# frozen_string_literal: true

class Territories::ListItemComponent < ApplicationComponent
  include TerritoryAttributesConcern
  has :territory

  def actions
    [
      xls_action,
      download_pdf_action,
      contacts_action,
      new_contact_action,
      assignment_action,
      show_action,
      edit_action,
      delete_action
    ]
  end
end
