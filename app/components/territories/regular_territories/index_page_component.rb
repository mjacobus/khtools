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
      territory_actions: territory_actions,
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

  def list_actions
    [new_action]
  end

  def new_action
    link_to(t('app.links.new'), send("new_admin_db_#{type}_territory_path"), class: 'btn')
  end

  def territory_actions
    [
      edit_action,
      delete_action
    ]
  end

  def edit_action
    proc do |territory|
      link_to(t('app.links.edit'), [:edit, :admin, territory], class: 'btn')
    end
  end

  def delete_action
    proc do |territory|
      link_to(
        t('app.links.delete'),
        admin_db_regular_territory_path(territory),
        data: { method: :delete, confirm: t('app.messages.confirm_delete') },
        class: 'btn'
      )
    end
  end
end
