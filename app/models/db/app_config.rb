# frozen_string_literal: true

module Db
  class AppConfig < ApplicationRecord
    KEYS = [
      'public_talks.contact_speaker_message'
    ].freeze

    validates :key, uniqueness: { case_sensitive: false }
    validates :value, presence: true
  end
end
