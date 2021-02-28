# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingAttendance::MeetingsController, type: :request do
  describe 'GET #index' do
    let(:perform_request) { get meeting_attendance_meetings_url }
    let(:meeting) { TestFactories.new.meetings.create }

    before do
      meeting
    end

    it 'responds with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'lists meetings by creation_date' do
      perform_request

      expect(response.body).to include(meeting.title)
    end
  end
end
