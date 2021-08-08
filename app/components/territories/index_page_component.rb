# frozen_string_literal: true

class Territories::IndexPageComponent < PageComponent
  attr_reader :territories
  attr_reader :title
  attr_reader :type

  def initialize(
    territories:,
    title:,
    type: :regular
  )
    @territories = territories
    @title = title
    @type = type
    breadcrumb.add_item(t('app.links.territories'))
    breadcrumb.add_item(t("app.links.#{type}_territories"))
  end

  def search_form
    Territories::SearchFormComponent.new(prototype: prototype, params: params)
  end

  def actions
    [new_action]
  end

  private

  def prototype
    "Db::#{type.to_s.classify}Territory".constantize.new
  end

  def new_action
    link_to(t('app.links.new'), send("new_territories_#{type}_territory_path"), class: 'btn')
  end
end
