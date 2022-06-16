# frozen_string_literal: true

module Db
  module MeetingAttendance
    class SimpleCounterAttendee < ApplicationRecord
      belongs_to :meeting
    end
  end
end
