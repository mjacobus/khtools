# frozen_string_literal: true

class Db::Territory < ApplicationRecord
  belongs_to :assignee, class_name: 'Publisher', optional: true
  belongs_to :territory, class_name: 'Territory', optional: true

  default_scope { order(:name) }
  identifiable_by :name

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :type }
end
