# frozen_string_literal: true

class Db::LetterBoxType < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
