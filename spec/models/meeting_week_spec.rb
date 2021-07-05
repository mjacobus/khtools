# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingWeek do
  subject(:week) { described_class.new(Date.new(2021, 7, 3)) }

  it 'has Monday as a first day' do
    expect(week.first_day).to eq(Date.new(2021, 6, 28))
  end

  it 'has Sunday as last day' do
    expect(week.last_day).to eq(Date.new(2021, 7, 4))
  end

  describe '#include?' do
    subject(:week) { described_class.new }

    it 'returns true when includes' do
      expect(week).to include(Time.zone.today)
    end

    it 'returns false when includes' do
      expect(week).not_to include(7.days.ago)
      expect(week).not_to include(7.days.from_now)
    end
  end

  describe '#cover?' do
    subject(:week) { described_class.new }

    it 'returns true when includes' do
      expect(week).to cover(Time.zone.today)
    end

    it 'returns false when includes' do
      expect(week).not_to cover(8.days.ago)
      expect(week).not_to cover(8.days.from_now)
    end
  end
end
