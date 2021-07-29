# frozen_string_literal: true

class Territories::RegularTerritories::IndexPageComponent < PageComponent
  attr_reader :territories

  def initialize(territories)
    @territories = territories
    setup_breadcrumb
  end

  def call
    render Territories::CommonIndexPageComponent.new(
      territories: territories,
      breadcrumb: breadcrumb,
      title: model.model_name.human,
      list_actions: list_actions,
      type: type
    )
  end

  private

  def setup_breadcrumb
    breadcrumb.add_item(t("app.links.#{type}_territories"))
  end

  def model
    Db::RegularTerritory
  end

  def type
    :regular
  end

end
