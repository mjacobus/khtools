# frozen_string_literal: true

class Db::Location < ApplicationRecord
  belongs_to :territory

  validates :address, presence: true
  validates :street_name, presence: true
  validates :number, presence: true

  def contacted_in_last_assignment?
    if last_contacted_at.nil? || territory.last_assignment.nil?
      return false
    end

    last_assignment = territory.last_assignment

    if last_assignment.returned?
      (last_assignment.assigned_at..last_assignment.returned_at).cover?(last_contacted_at)
    end

    last_contacted_at > last_assignment.assigned_at
  end
end
