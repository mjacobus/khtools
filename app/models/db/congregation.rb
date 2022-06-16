# frozen_string_literal: true

module Db
  class Congregation < ApplicationRecord
    validates :name, presence: true

    default_scope { order(local: :desc).order(:name) }
    scope :local, -> { where(local: true) }
  end
end
