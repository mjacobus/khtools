# frozen_string_literal: true

class Congregations::ShowPageComponent < PageComponent
  attr_reader :congregation

  def initialize(congregation)
    @congregation = congregation

    breadcrumb.add_item(t('app.links.congregations'), urls.public_talks_congregations_path)
    breadcrumb.add_item(congregation.name)
  end

  def edit_link
    link_to(t('app.links.edit'), edit_public_talks_congregation_path(congregation))
  end

  def destroy_link
    link_to(
      t('app.links.delete'), public_talks_congregation_path(congregation),
      data: { method: :delete, confirm: delete_confirmation(congregation) }
    )
  end

  def has_contact_information?
    [
      congregation.primary_contact_person,
      congregation.primary_contact_email,
      congregation.primary_contact_phone
    ].map(&:presence).compact.any?
  end

  private

  def delete_confirmation(congregation)
    t('app.messages.confirm_delete_x', record: congregation.name)
  end
end
