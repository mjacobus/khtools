# frozen_string_literal: true

class Db::Account < ApplicationRecord
  validates :congregation_name, uniqueness: { case_sensitive: false }, presence: true
end
