# frozen_string_literal: true

class PublicTalks::Talks::IndexPageComponent < PageComponent
  attr_reader :talks

  def initialize(talks)
    @sql = talks.to_sql # for testing purposes
    @talks = talks
    setup_breadcrumb
    @week = MeetingWeek.new
  end

  def showing_talks_since
    if since
      t('app.messages.showing_public_talks_since', date: l(since))
    end
  end

  def new_link
    link_to(t('app.links.new'), new_public_talks_talk_path)
  end

  def edit_link(talk)
    link_to(t('app.links.edit'), edit_public_talks_talk_path(talk))
  end

  def destroy_link(talk)
    link_to(
      t('app.links.delete'), public_talks_talk_path(talk),
      data: { method: :delete, confirm: delete_confirmation(talk) }
    )
  end

  def show_link(talk)
    link_to(t('app.links.view'), public_talks_talk_path(talk))
  end

  def speaker_name(talk)
    "#{talk&.speaker&.name} (#{talk&.speaker&.congregation&.name})"
  end

  def theme(talk)
    talk.theme_object
  end

  def classes(talk)
    classes = []

    if talk.congregation.present?
      classes << talk.congregation.local? ? 'local' : 'outcoing'
    end

    if @week.cover?(talk.date)
      classes << 'current'
    end

    classes.join(' ')
  end

  private

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

  def delete_confirmation(talk)
    t('app.messages.confirm_delete_x', record: talk.summary)
  end

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.public_talks'))
  end
end
