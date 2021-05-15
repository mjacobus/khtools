# frozen_string_literal: true

class Db::PhoneListTerritory < Db::Territory
  validates :initial_phone_number, presence: true
  validates :final_phone_number, presence: true

  def phone_numbers
    if initial_phone_number.present? && final_phone_number.present?
      return (initial_phone_number..final_phone_number).to_a
    end

    []
  end
end
