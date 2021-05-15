# frozen_string_literal: true

class Db::Territory < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  belongs_to :assignee, class_name: 'Publisher', optional: true
end
