# frozen_string_literal: true

class Db::PublicSpeaker < ApplicationRecord
  belongs_to :congregation

  validates :name, presence: true
end
