# frozen_string_literal: true

class Territories::CommonIndexPageComponent < PageComponent
  attr_reader :territories
  attr_reader :breadcrumb
  attr_reader :title
  attr_reader :territory_actions
  attr_reader :list_actions
  attr_reader :type

  def initialize(
    territories:,
    breadcrumb:,
    title:,
    territory_actions: [],
    list_actions: [],
    type: :regular
  )
    @territories = territories
    @breadcrumb = breadcrumb
    @title = title
    @territory_actions = territory_actions
    @list_actions = list_actions
    @type = type
  end

  def search_form
    Territories::SearchFormComponent.new(type: type, params: params)
  end
end
