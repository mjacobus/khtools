# frozen_string_literal: true

class Territories::FormPageComponent < PageComponent
  attr_reader :territory

  def initialize(territory:)
    @territory = territory
    breadcrumb.add_item(
      t("app.links.#{type}_territories"),
      urls.territories_path(type)
    )

    if territory.id
      breadcrumb.add_item(territory.name)
      breadcrumb.add_item(t('app.links.edit'))
      return
    end

    breadcrumb.add_item(t('app.links.new'))
  end

  def target_url
    if territory.id
      return urls.send("territories_#{type}_territory_path", territory)
    end

    urls.send("territories_#{type}_territories_path")
  end

  def publishers
    Db::Publisher.all.pluck(:name, :id)
  end

  def phone_providers
    Db::PhoneProvider.all.pluck(:name, :id)
  end

  def type
    @territory.type_key
  end

  def territory_collection
    Db::RegularTerritory.order(:name).pluck(:name, :id)
  end

  def area_collection
    Db::TerritoryArea.pluck(:name, :id)
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
end
