# frozen_string_literal: true

class Territories::RegularTerritories::IndexPageComponent < PageComponent
  attr_reader :territories

  def initialize(territories)
    @territories = territories
    setup_breadcrumb
  end

  def title
    Db::RegularTerritory.model_name.human
  end

  private

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.commercial_territories'))
  end
end
