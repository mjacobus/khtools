# frozen_string_literal: true

class Territories::FormPageComponent < PageComponent
  attr_reader :territory

  def initialize(territory:)
    @territory = territory
    breadcrumb.add_item(t("app.links.#{type}_territories"))

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
    @type ||= @territory.class.to_s.underscore.split('/').last.sub('_territory', '')
  end
end
