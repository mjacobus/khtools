# frozen_string_literal: true

class Db::LetterBoxType < ApplicationRecord
  has_many :territories,
           class_name: 'Territory',
           inverse_of: :letter_box_type,
           dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
