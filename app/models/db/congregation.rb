# frozen_string_literal: true

class Db::Congregation < ApplicationRecord
  validates :name, presence: true
end
