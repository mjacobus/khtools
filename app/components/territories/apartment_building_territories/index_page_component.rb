# frozen_string_literal: true

class Territories::ApartmentBuildingTerritories::IndexPageComponent < PageComponent
  attr_reader :territories

  def initialize(territories)
    @territories = territories
    setup_breadcrumb
  end

  def title
    Db::ApartmentBuildingTerritory.model_name.human
  end

  private

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.apartment_building_territories'))
  end
end
