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
    breadcrumb.add_item(t("app.links.#{type}_territories"))
  end

  def search_form
    Territories::SearchFormComponent.new(type: type, params: params)
  end

  def actions
    [new_action]
  end

  private

  def new_action
    link_to(t('app.links.new'), send("new_territories_#{type}_territory_path"), class: 'btn')
  end
end
