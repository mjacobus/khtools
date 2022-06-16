# frozen_string_literal: true

module PublicTalks
  class ContactSpeakerMessageComponent < ApplicationComponent
    attr_reader :talk

    def initialize(talk)
      @talk = talk
    end

    def render?
      message.present? && talk.congregation.present? && talk.speaker.present?
    end

    def formatted_message
      simple_format(text_message)
    end

    def contact_info
      ContactInfoComponent.new(phone: talk&.speaker&.phone, email: talk&.speaker&.email, message: text_message)
    end

    private

    def text_message
      @text_message ||= replace(message, variables)
    end

    def variables
      {
        'congregation.name' => local_congregation_name,
        'speaker.congregation' => talk.speaker.congregation_name,
        'speaker.first_name' => talk.speaker.name.split.first,
        'speaker.name' => talk.speaker.name,
        'talk.date' => l(talk.date, format: :short),
        'talk.speaker' => talk.speaker.name,
        'talk.theme' => PublicTalks::Theme.new(talk.theme).to_s,
        'user.name' => current_user.name
      }
    end

    def local_congregation_name
      Db::Congregation.local.first&.name
    end

    def replace(message, values)
      values.each do |key, value|
        key = "{{#{key}}}"
        message = message.gsub(key, value)
      end
      message
    end

    def message
      @message ||= Db::AppConfig.find_by(key: 'public_talks.contact_speaker_message')&.value
    end
  end
end
