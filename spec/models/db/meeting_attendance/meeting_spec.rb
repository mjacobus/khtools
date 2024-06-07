# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::MeetingAttendance::Meeting do
  let(:factories) { TestFactories.new }
  let(:meeting) { factories.meetings.build }

  it 'persists a meeting' do
    expect { meeting.save! }.to change(described_class, :count).by(1)
  end

  it 'requires a name' do
    meeting.title = nil

    expect(meeting).not_to be_valid
  end
end
