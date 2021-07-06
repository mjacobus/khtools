# frozen_string_literal: true

class PublicTalks::Speakers::ShowPageComponent < PageComponent
  attr_reader :speaker

  def initialize(speaker)
    @speaker = speaker

    breadcrumb.add_item(t('app.links.public_speakers'), urls.public_talks_speakers_path)
    breadcrumb.add_item(speaker.name)
  end

  def edit_link
    link_to(t('app.links.edit'), edit_public_talks_speaker_path(speaker))
  end

  def destroy_link
    link_to(
      t('app.links.delete'), public_talks_speaker_path(speaker),
      data: { method: :delete, confirm: delete_confirmation(speaker) }
    )
  end

  private

  def delete_confirmation(speaker)
    t('app.messages.confirm_delete_x', record: speaker.name)
  end
end
