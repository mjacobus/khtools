# frozen_string_literal: true

class MeetingAttendance::SimpleCounterAttendeesForm < BaseForm
  attr_reader :names
  attr_accessor :amount

  def initialize(meeting)
    super(Db::MeetingAttendance::SimpleCounterAttendee.new)
    @meeting = meeting
    @names = []
    @amount = 1
  end

  def params=(params)
    self.attributes = params.require(:attendee).permit(:names, :amount)
  end

  def names=(names)
    @names = Array(names).join(',').split(',').map do |name|
      name.strip.presence
    end.compact
  end

  def save
    names.each do |name|
      @meeting.attendees.create(name: name, amount: amount)
    end
  end

  private

  def param_key
    'attendee'
  end

  def singular_route_key
    'meeting_attendance_meeting_simple_counter_attendee'
  end
end
