# frozen_string_literal: true

class Territories::Assignments::NewPageComponent < PageComponent
  include TerritoryAttributesConcern

  attr_reader :territory

  def initialize(territory:)
    @territory = territory
    breadcrumb.add_item(
      t("app.links.#{type}_territories"),
      urls.territories_path(type)
    )

    if territory.id
      breadcrumb.add_item(territory.name, urls.territory_path(territory))
      breadcrumb.add_item(t('app.links.assign_territory'))
      return
    end

    breadcrumb.add_item(t('app.links.new'))
  end

  def publishers
    Db::Publisher.all.pluck(:name, :id)
  end

  def target_url
    urls.territory_assignments_path(territory)
  end
end
