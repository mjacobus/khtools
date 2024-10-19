# frozen_string_literal: true

class Db::Location < ApplicationRecord
  belongs_to :territory

  validates :address, presence: true
  validates :street_name, presence: true
  validates :number, presence: true
  validates :block_number, presence: true
end
