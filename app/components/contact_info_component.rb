# frozen_string_literal: true

class ContactInfoComponent < ApplicationComponent
  attr_reader :email, :phone

  def initialize(phone: nil, email: nil, message: nil)
    @phone = phone
    @email = email
    @message = message
  end

  def has_contact_information?
    [email, phone].filter_map(&:presence).any?
  end

  def whatsapp_url
    message = ERB::Util.url_encode(@message)
    link_to(
      'WhatsApp',
      "https://wa.me/#{phone_number}?text=#{message}",
      target: :blank
    )
  end

  private

  def phone_number
    "55#{PhoneNumber.new(phone).unformatted}"
  end
end
