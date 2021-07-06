# frozen_string_literal: true

class Db::Congregation < ApplicationRecord
  validates :name, presence: true

  default_scope { order(local: :desc).order(:name) }
end
