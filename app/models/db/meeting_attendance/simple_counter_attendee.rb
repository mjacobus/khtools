# frozen_string_literal: true

class Db::MeetingAttendance::SimpleCounterAttendee < ApplicationRecord
  belongs_to :meeting
end
