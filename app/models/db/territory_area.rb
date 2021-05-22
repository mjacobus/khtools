# frozen_string_literal: true

class Db::TerritoryArea < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
