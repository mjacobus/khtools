# frozen_string_literal: true

class Home::DashboardComponent < PageComponent
  def render?
    current_user
  end

  def talks(&block)
    segregate_talks(week_talks, &block)
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

  def field_service_groups
    Db::FieldServiceGroup.with_dependencies.active.order(:name)
  end

  private

  def week_talks
    @week_talks ||= Db::PublicTalk.within_week.with_dependencies
  end

  def segregate_talks(talks)
    yield(talks.select(&:local?), talks.reject(&:local?))
  end
end
