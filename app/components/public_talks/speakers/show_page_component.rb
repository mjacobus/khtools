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

  def has_contact_information?
    [speaker.email, speaker.phone].map(&:presence).compact.any?
  end

  def whatsapp_web_link
    link_to(
      'Web',
      "https://web.whatsapp.com/send?phone=#{phone_number}",
      target: :blank
    )
  end

  def whatsapp_api_link
    link_to(
      'APP',
      "https://api.whatsapp.com/send?phone=#{phone_number}",
      target: :blank
    )
  end

  private

  def delete_confirmation(speaker)
    t('app.messages.confirm_delete_x', record: speaker.name)
  end

  def phone_number
    "55#{PhoneNumber.new(speaker.phone).unformatted}"
  end
end
