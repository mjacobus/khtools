# frozen_string_literal: true

class Db::Account < ApplicationRecord
  validates :congregation_name, uniqueness: { case_sensitive: false }, presence: true

  has_many :users, dependent: :restrict_with_exception
end
