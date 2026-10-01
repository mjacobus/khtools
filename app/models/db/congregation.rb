# frozen_string_literal: true

class Db::Congregation < ApplicationRecord
  belongs_to :account, class_name: 'Db::Account'

  validates :name, presence: true

  default_scope { order(local: :desc).order(:name) }
  scope :local, -> { where(local: true) }
end
