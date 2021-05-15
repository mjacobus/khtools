# frozen_string_literal: true

class Db::PhoneListTerritory < Db::Territory
  validates :initial_phone_number, presence: true
  validates :final_phone_number, presence: true
end
