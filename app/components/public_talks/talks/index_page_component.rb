# frozen_string_literal: true

class PublicTalks::Talks::IndexPageComponent < PageComponent
  attr_reader :talks

  def initialize(talks)
    @sql = talks.to_sql # for testing purposes
    @talks = talks
    setup_breadcrumb
  end

  def showing_talks_since
    if since
      t('app.messages.showing_public_talks_since', date: l(since))
    end
  end

  def see_all_link
    link_to(
      t('app.links.see_all'),
      public_talks_talks_path,
      class: 'btn btn-primary float-right'
    )
  end

  def new_link
    link_to(t('app.links.new'), new_public_talks_talk_path)
  end

  def grouped_by_week
    @talks.group_by do |talk|
      MeetingWeek.new(talk.date).first_day
    end
  end

  def segregate(talks)
    yield(talks.select { |t| local?(t) }, talks.reject { |t| local?(t) })
  end

  private

  def local?(talk)
    talk&.congregation&.local?
  end

  def since
    if defined?(@since)
      return @since
    end

    @since = begin
      Date.parse(params[:since])
    rescue StandardError
      nil
    end
  end

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.public_talks'))
  end
end
