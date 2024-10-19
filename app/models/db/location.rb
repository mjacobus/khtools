# frozen_string_literal: true

class Db::Location < ApplicationRecord
  belongs_to :territory

  validates :street, presence: true
  validates :street_number, presence: true
  validates :block_number, presence: true
end
