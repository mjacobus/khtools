# frozen_string_literal: true

class Db::Contact < ApplicationRecord
  validates :name, presence: true
end
