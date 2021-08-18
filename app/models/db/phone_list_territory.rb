# frozen_string_literal: true

class Db::PhoneListTerritory < Db::Territory
  validates :initial_phone_number, presence: true
  validates :final_phone_number, presence: true
  belongs_to :phone_provider

  def phone_numbers
    if initial_phone_number.present? && final_phone_number.present?
      return (initial_phone_number..final_phone_number).to_a.map do |num|
        PhoneNumber.new(num)
      end
    end

    []
  end

  def self.with_dependencies
    super.includes(:phone_provider)
  end

  def editable_attributes
    super + %i[
      initial_phone_number
      final_phone_number
      phone_provider_id
    ]
  end

  def filename(extension = nil)
    [name, extension].compact.join('.')
  end
end
