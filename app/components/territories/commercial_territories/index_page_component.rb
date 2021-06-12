# frozen_string_literal: true

class Territories::CommercialTerritories::IndexPageComponent < ApplicationComponent
  attr_reader :territories

  def initialize(territories)
    @territories = territories
  end

  def title
    Db::CommercialTerritory.model_name.human
  end

  def contacts_text(territory)
    I18n.t('app.messages.x_contacts', count: territory.contacts.count)
  end
end
