# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingAttendance::SimpleCounterController, type: :request do
  let(:factories) { TestFactories.new }
  let(:meeting) { factories.meetings.create }

  describe 'POST #create' do
    let(:perform_request) do
      post meeting_attendance_meeting_simple_counter_attendees_url(meeting),
           params: { attendee: { name: "foo, bar baz , , \nfizbuz" } }
    end

    it 'adds attendees' do
      perform_request

      expect(meeting.attendees.pluck(:name)).to eq(['foo', 'bar baz', 'fizbuz'])
    end

    it 'redirects to index' do
      perform_request

      expect(response).to redirect_to(meeting_attendance_meeting_simple_counter_attendees_url)
    end
  end

  describe 'DELETE #destroy' do
    let(:perform_request) do
      delete meeting_attendance_meeting_simple_counter_attendee_url(meeting, attendee)
    end
    let(:attendee) { factories.attendees.create(meeting: meeting) }

    before { attendee }

    it 'removes the attendee' do
      expect { perform_request }.to change { meeting.attendees.count }.by(-1)
    end

    it 'redirects to index' do
      perform_request

      expect(response).to redirect_to(meeting_attendance_meeting_simple_counter_attendees_url)
    end
  end
end
