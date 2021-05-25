# frozen_string_literal: true

class Db::PreachingMethod < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
