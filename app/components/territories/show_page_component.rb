# frozen_string_literal: true

class Territories::ShowPageComponent < PageComponent
  include TerritoryAttributesConcern

  has :territory
  attr_reader :access_token

  def actions
    [
      assignment_action,
      assignments_action,
      public_view_action,
      xls_action,
      download_pdf_action,
      edit_action,
      delete_action,
      create_link_to_files_action
    ].compact
  end

  def territory_attribute(name)
    attribute(name).with_label.without_icon
  end

  def with_access_token(token)
    @access_token = token
    self
  end

  def create_link_to_files_action
    url = urls.territory_tokenized_files_path(territory)
    link_to(t('app.links.create_tokenized_link_to_files'), url, data: { method: :post }, class: 'btn')
  end

  def tokenized_pdf_link
    url = urls.territory_download_pdf_path(territory, access_token: access_token.token)
    "#{root_url}#{url}"
  end

  def tokenized_xls_link
    url = urls.territory_download_xls_path(territory, access_token: access_token.token)
    "#{root_url}#{url}"
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
