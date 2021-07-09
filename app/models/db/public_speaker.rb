# frozen_string_literal: true

class Db::PublicSpeaker < ApplicationRecord
  belongs_to :congregation

  scope :with_dependencies, -> { includes(:congregation) }

  validates :name, presence: true
end
