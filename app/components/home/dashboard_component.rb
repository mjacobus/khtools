# frozen_string_literal: true

class Home::DashboardComponent < PageComponent
  def render?
    current_user
  end

  def talks(&)
    segregate_talks(week_talks, &)
  end

  def talks_title
    t('app.titles.week_talks')
  end

  def publishers_title
    t('app.links.publishers')
  end

  def display_week_talks?
    week_talks.any?
  end

  def my_territories_title
    t('app.titles.my_territories')
  end

  def display_my_territories?
    my_publisher.present?
  end

  def my_territories
    @my_territories ||= current_account.territories.where(assignee: my_publisher).order(:name)
  end

  def territory_link(territory)
    link_to(territory.name, urls.territory_path(territory))
  end

  def territory_type(territory)
    territory.class.model_name.human
  end

  def assigned_since(territory)
    if territory.assigned_at
      t('app.messages.assigned_since', date: l(territory.assigned_at.to_date))
    end
  end

  def field_service_groups
    current_account.field_service_groups.active.with_dependencies.order(:name)
  end

  private

  def my_publisher
    current_user.publisher
  end

  def week_talks
    @week_talks ||= Db::PublicTalk.within_week.with_dependencies
  end

  def segregate_talks(talks)
    yield(talks.select(&:local?), talks.reject(&:local?))
  end
end
