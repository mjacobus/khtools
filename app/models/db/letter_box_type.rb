# frozen_string_literal: true

module Db
  class LetterBoxType < ApplicationRecord
    has_many :territories,
             class_name: 'Territory',
             inverse_of: :letter_box_type,
             dependent: :restrict_with_exception

    validates :name, presence: true, uniqueness: { case_sensitive: false }
  end
end
