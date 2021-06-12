# frozen_string_literal: true

class Territories::CommercialTerritories::IndexPageComponent < PageComponent
  attr_reader :territories

  def initialize(territories)
    @territories = territories
    setup_breadcrumb
  end

  def title
    Db::CommercialTerritory.model_name.human
  end

  def contacts_text(territory)
    I18n.t('app.messages.x_contacts', count: territory.contacts.count)
  end

  private

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.commercial_territories'))
  end
end
