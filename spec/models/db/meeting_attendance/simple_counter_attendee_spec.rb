# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::MeetingAttendance::SimpleCounterAttendee do
  let(:attendee) { TestFactories.new.attendees.create(name: 'John Doe') }

  it 'belongs to meeting' do
    expect(attendee.meeting).to be_a(Db::MeetingAttendance::Meeting)

    attendees = attendee.meeting.attendees
    expect(attendees).to eq([attendee])
  end
end
