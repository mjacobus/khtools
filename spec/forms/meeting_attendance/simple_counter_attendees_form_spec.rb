# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingAttendance::SimpleCounterAttendeesForm do
  let(:form) { described_class.new(model) }
  let(:model) { Db::MeetingAttendance::Meeting.new }

  describe '#model_name' do
    it 'return the correct model name' do
      expect(form.model_name.param_key).to eq('attendee')
      expect(form.model_name.singular_route_key)
        .to eq('meeting_attendance_meeting_simple_counter_attendee')
    end
  end
end
