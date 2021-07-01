# frozen_string_literal: true

class PublicTalks::Talks::ShowPageComponent < PageComponent
  attr_reader :talk

  def initialize(talk)
    @talk = talk

    breadcrumb.add_item(t('app.links.public_talks'), urls.public_talks_talks_path)
    breadcrumb.add_item(talk.summary)
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

  def has_contact_information?
    [talk.email, talk.phone].map(&:presence).compact.any?
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

  def phone_number
    "55#{PhoneNumber.new(talk.phone).unformatted}"
  end
end
