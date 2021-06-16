# frozen_string_literal: true

class Territories::PhoneListTerritories::IndexPageComponent < PageComponent
  attr_reader :territories

  def initialize(territories)
    @territories = territories
    setup_breadcrumb
  end

  def title
    Db::PhoneListTerritory.model_name.human
  end

  private

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.phone_list_territories'))
  end
end
