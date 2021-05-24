# frozen_string_literal: true

class Db::IntercomType < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
