# frozen_string_literal: true

class Db::Territory < ApplicationRecord
  default_scope { order(:name) }

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :type }
  belongs_to :assignee, class_name: 'Publisher', optional: true
end
