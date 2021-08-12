# frozen_string_literal: true

class ContactInfoComponent < ApplicationComponent
  attr_reader :email
  attr_reader :phone

  def initialize(phone: nil, email: nil)
    @phone = phone
    @email = email
  end

  def has_contact_information?
    [email, phone].filter_map(&:presence).any?
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

  def phone_number
    "55#{PhoneNumber.new(phone).unformatted}"
  end
end
