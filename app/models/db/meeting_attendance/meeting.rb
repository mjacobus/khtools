# frozen_string_literal: true

class Db::MeetingAttendance::Meeting < ApplicationRecord
  validates :title, presence: true

  scope :by_creation_date, -> { order(created_at: :desc) }
end
