# frozen_string_literal: true

class PublicTalks::Speakers::FormPageComponent < PageComponent
  attr_reader :speaker

  def initialize(speaker)
    @speaker = speaker
    breadcrumb.add_item(t('app.links.public_speakers'), urls.public_talks_speakers_path)

    if speaker.id
      breadcrumb.add_item(
        speaker.name,
        urls.public_talks_speaker_path(speaker)
      )
      breadcrumb.add_item(t('app.links.edit'))
      return
    end

    breadcrumb.add_item(t('app.links.new'))
  end

  def target_url
    if speaker.id
      return public_talks_speaker_path(speaker)
    end

    public_talks_speakers_path
  end

  def collection_for_congregation
    Db::Congregation.pluck(:name, :id)
  end
end
