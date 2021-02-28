# frozen_string_literal: true

class Db::MeetingAttendance::Meeting < ApplicationRecord
  validates :title, presence: true
end
