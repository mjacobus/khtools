# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingAttendance::MeetingsController, type: :request do
  let(:model) { Db::MeetingAttendance::Meeting }
  let(:meeting) { TestFactories.new.meetings.create }

  before do
    grant_access(current_user)
  end

  describe 'GET #index' do
    let(:perform_request) { get meeting_attendance_meetings_url }

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

  describe '#new' do
    let(:perform_request) { get new_meeting_attendance_meeting_url }

    it 'responds with success' do
      perform_request

      expect(response).to be_successful
    end
  end

  describe '#edit' do
    let(:perform_request) { get edit_meeting_attendance_meeting_url(meeting) }

    it 'responds with success' do
      perform_request

      expect(response).to be_successful
    end
  end

  describe '#create' do
    let(:perform_request) { post meeting_attendance_meetings_url, params: }
    let(:params) { { meeting: { title: 'A Meeting' } } }

    it 'redirects to index' do
      perform_request

      expect(response).to redirect_to(meeting_attendance_meetings_url)
    end

    it 'creates a meeting' do
      expect { perform_request }.to change(model, :count).by(1)
    end

    context 'when payload is invalid' do
      before do
        params[:meeting][:title] = ''
      end

      it 're-renders the form' do
        perform_request

        expect(response.status).to eq(422)
        expect(response.body).to include(I18n.t('simple_form.error_notification.default_message'))
      end
    end
  end

  describe '#update' do
    let(:perform_request) { patch meeting_attendance_meeting_url(meeting), params: }
    let(:params) { { meeting: { title: 'A Meeting' } } }

    it 'redirects to index' do
      perform_request

      expect(response).to redirect_to(meeting_attendance_meetings_url)
    end

    it 'creates a meeting' do
      expect { perform_request }.to change(model, :count).by(1)
    end

    context 'when payload is invalid' do
      before do
        params[:meeting][:title] = ''
      end

      it 're-renders the form' do
        perform_request

        expect(response.status).to eq(422)
        expect(response.body).to include(I18n.t('simple_form.error_notification.default_message'))
      end
    end
  end

  describe '#destroy' do
    let(:perform_request) { delete meeting_attendance_meeting_url(meeting) }

    before { meeting }

    it 'redirects to index' do
      perform_request

      expect(response).to redirect_to(meeting_attendance_meetings_url)
    end

    it 'deletes the meeting' do
      expect { perform_request }.to change(model, :count).by(-1)
    end
  end
end
