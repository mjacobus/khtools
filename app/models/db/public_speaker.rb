# frozen_string_literal: true

class Db::PublicSpeaker < ApplicationRecord
  belongs_to :congregation, optional: true

  scope :with_dependencies, -> { includes(:congregation) }

  validates :name, presence: true

  def congregation_name
    congregation&.name
  end
end
