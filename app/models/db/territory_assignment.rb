# frozen_string_literal: true

class Db::TerritoryAssignment < ApplicationRecord
  belongs_to :territory
  belongs_to :assignee, class_name: 'Publisher'

  validates :assigned_at, presence: true
end
