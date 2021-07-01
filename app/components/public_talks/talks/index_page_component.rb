# frozen_string_literal: true

class PublicTalks::Talks::IndexPageComponent < PageComponent
  attr_reader :talks

  def initialize(talks)
    @talks = talks
    setup_breadcrumb
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

  private

  def delete_confirmation(talk)
    t('app.messages.confirm_delete_x', record: talk.summary)
  end

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.public_talks'))
  end
end
