# frozen_string_literal: true

class Home::DashboardComponent < PageComponent
  def talks(&block)
    segregate_talks(Db::PublicTalk.within_week, &block)
  end

  def talks_title
    t('app.titles.week_talks')
  end

  private

  def segregate_talks(talks)
    yield(talks.select(&:local?), talks.reject(&:local?))
  end
end
