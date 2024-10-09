# frozen_string_literal: true

class Territories::FormPageComponent < PageComponent
  has :territory

  def target_url
    if territory.id
      return urls.send(:"territories_#{type}_territory_path", territory)
    end

    urls.send(:"territories_#{type}_territories_path")
  end

  def publishers
    current_account.publishers.pluck(:name, :id)
  end

  def phone_providers
    Db::PhoneProvider.pluck(:name, :id)
  end

  def type
    territory.type_key
  end

  def territory_collection
    current_account.territories.regular.order(:name).pluck(:name, :id)
  end

  def field_service_group_options
    current_account.field_service_groups.pluck(:name, :id)
  end

  def area_collection
    Db::TerritoryArea.pluck(:name, :id)
  end

  def fetch_address_params
    {
      latitudeSelector: '#territory_latitude',
      longitudeSelector: '#territory_longitude',
      addressSelector: '#territory_address'
    }
  end

  def intercom_type_collection
    Db::IntercomType.pluck(:name, :id)
  end

  def letter_box_type_collection
    Db::LetterBoxType.pluck(:name, :id)
  end

  def preaching_method_collection
    Db::PreachingMethod.pluck(:name, :id)
  end

  def boolean_collection
    [[I18n.t('true'), true], [I18n.t('false'), false]]
  end

  def assignment_editable?
    # as of this moment, editing assignments won't fix the assignment history.
    # So maybe not a good idea to edit it in the form.
    false
  end

  def supports_upload?
    territory.editable_attributes.include?(:file) && current_account.supports_uploads?
  end

  def static_map?
    territory.has_static_map?
  end

  def static_map_url
    @static_map_url ||= territory.static_map_url.to_s
  end

  private

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.territories'))

    breadcrumb.add_item(
      t("app.links.#{type}_territories"),
      urls.territories_path(type)
    )

    if territory.id
      breadcrumb.add_item(territory.name, urls.territory_path(territory))
      breadcrumb.add_item(t('app.links.edit'))
      return
    end

    breadcrumb.add_item(t('app.links.new'))
  end
end
