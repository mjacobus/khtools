# frozen_string_literal: true

class Db::TerritoryAssignment < ApplicationRecord
  belongs_to :territory
  belongs_to :assignee, class_name: 'Publisher'

  validates :assigned_at, presence: true

  def returned?
    returned_at.present?
  end

  def return
    self.returned_at = Time.zone.now
    save!
  end
end
