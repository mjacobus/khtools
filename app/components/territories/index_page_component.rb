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
    Territories::SearchFormComponent.new(prototype:, params:)
  end

  def actions
    [new_action]
  end

  def display_my_territories_filter?
    my_publisher.present?
  end

  def my_territories_filter_links
    [
      filter_link(t('app.links.all'), nil),
      filter_link(t('app.links.mine'), my_publisher.id.to_s)
    ]
  end

  private

  def my_publisher
    current_user.publisher
  end

  def filter_link(text, publisher_id)
    active = params[:publisher_id].presence == publisher_id
    classes = class_names('btn btn-sm', active ? 'btn-primary' : 'btn-outline-primary')
    link_to(text, url_for(publisher_id:), class: classes, 'aria-current': (active ? 'true' : nil))
  end

  def prototype
    "Db::#{type.to_s.classify}Territory".constantize.new
  end

  def new_action
    link_to(t('app.links.new'), send(:"new_territories_#{type}_territory_path"), class: 'btn')
  end
end
