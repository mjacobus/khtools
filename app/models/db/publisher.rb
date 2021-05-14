# frozen_string_literal: true

module Db
  class Publisher < ApplicationRecord
    validates :name, presence: true
    validates :gender, presence: true
  end
end
