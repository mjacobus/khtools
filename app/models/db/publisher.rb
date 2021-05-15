# frozen_string_literal: true

class Db::Publisher < ApplicationRecord
  default_scope { order(:name) }
  belongs_to :group, class_name: 'FieldServiceGroup'

  validates :name, presence: true
  validates :gender, presence: true
end
