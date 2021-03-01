# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingAttendance::MeetingForm, type: :form do
  let(:form) { described_class.new(model) }
  let(:model) { Db::MeetingAttendance::Meeting.new }

  describe '#model_name' do
    it 'return the correct model name' do
      expect(form.model_name.param_key).to eq('meeting')
      expect(form.model_name.singular_route_key).to eq('meeting_attendance_meeting')
    end
  end
end
