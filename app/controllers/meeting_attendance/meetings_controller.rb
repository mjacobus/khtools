# frozen_string_literal: true

class MeetingAttendance::MeetingsController < ApplicationController
  def index
    @meetings = Db::MeetingAttendance::Meeting.by_creation_date
  end
end
