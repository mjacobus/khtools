# frozen_string_literal: true

class PublicTalks::Talks::ListItemComponent < PageComponent
  attr_reader :talk

  def initialize(talk)
    @talk = talk
    @week = MeetingWeek.new
  end

  def edit_link
    link_to(t('app.links.edit'), edit_public_talks_talk_path(talk))
  end

  def destroy_link
    link_to(
      t('app.links.delete'), public_talks_talk_path(talk),
      data: { method: :delete, confirm: delete_confirmation(talk) }
    )
  end

  def show_link
    link_to(t('app.links.view'), public_talks_talk_path(talk))
  end

  def speaker_name(talk)
    "#{talk&.speaker&.name} (#{talk&.speaker&.congregation&.name})"
  end

  def theme(talk)
    talk.theme_object
  end

  def classes
    classes = []

    if talk.congregation.present?
      classes << (talk.congregation.local? ? 'local' : 'non-local')
    end

    if @week.cover?(talk.date)
      classes << 'current'
    end

    classes.join(' ')
  end

  private

  def delete_confirmation(talk)
    t('app.messages.confirm_delete_x', record: talk.summary)
  end
end
