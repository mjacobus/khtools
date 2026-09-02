# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceYear do
  describe '#initialize' do
    subject(:service_year) { described_class.new(2025) }

    it 'starts on september 1st' do
      expect(service_year.first_day).to eq(Date.new(2025, 9, 1))
    end

    it 'ends on august 31st of the following year' do
      expect(service_year.last_day).to eq(Date.new(2026, 8, 31))
    end

    it 'covers every day in between' do
      expect(service_year).to cover(Date.new(2025, 9, 1))
      expect(service_year).to cover(Date.new(2026, 1, 15))
      expect(service_year).to cover(Date.new(2026, 8, 31))
    end

    it 'does not cover days outside of the period' do
      expect(service_year).not_to cover(Date.new(2025, 8, 31))
      expect(service_year).not_to cover(Date.new(2026, 9, 1))
    end

    it 'accepts a year given as a string' do
      expect(described_class.new('2025')).to eq(service_year)
    end
  end

  describe '.containing' do
    it 'returns the service year that started in the previous calendar year' do
      expect(described_class.containing(Date.new(2026, 8, 31)).year).to eq(2025)
    end

    it 'returns the service year that starts in september' do
      expect(described_class.containing(Date.new(2026, 9, 1)).year).to eq(2026)
    end

    it 'accepts a time' do
      expect(described_class.containing(Time.zone.local(2026, 9, 1, 10)).year).to eq(2026)
    end
  end

  describe '.current' do
    it 'is the service year containing today' do
      travel_to(Date.new(2026, 2, 10)) do
        expect(described_class.current.year).to eq(2025)
      end
    end
  end

  describe '.from_param' do
    it 'builds the service year for the given year' do
      expect(described_class.from_param('2025').year).to eq(2025)
    end

    it 'falls back to the current service year when the param is blank' do
      travel_to(Date.new(2026, 2, 10)) do
        expect(described_class.from_param(nil).year).to eq(2025)
      end
    end

    it 'falls back to the current service year when the param is not a year' do
      travel_to(Date.new(2026, 2, 10)) do
        expect(described_class.from_param('not-a-year').year).to eq(2025)
      end
    end

    it 'falls back when the year is out of any plausible range' do
      travel_to(Date.new(2026, 2, 10)) do
        expect(described_class.from_param('99999999999').year).to eq(2025)
        expect(described_class.from_param('-5').year).to eq(2025)
      end
    end

    it 'accepts a custom fallback' do
      fallback = described_class.new(2001)

      expect(described_class.from_param('', fallback:)).to eq(fallback)
    end
  end

  describe '#starts_at and #ends_at' do
    subject(:service_year) { described_class.new(2025) }

    it 'spans the whole first and last days' do
      expect(service_year.starts_at).to eq(Time.zone.local(2025, 9, 1, 0, 0, 0))
      expect(service_year.ends_at.to_date).to eq(Date.new(2026, 8, 31))
      expect(service_year.ends_at.hour).to eq(23)
    end
  end

  describe '#label' do
    it 'joins both calendar years' do
      expect(described_class.new(2025).label).to eq('2025/2026')
      expect(described_class.new(2025).to_s).to eq('2025/2026')
    end
  end

  describe '#to_param' do
    it 'is the starting year' do
      expect(described_class.new(2025).to_param).to eq('2025')
    end
  end

  describe '#previous and #following' do
    subject(:service_year) { described_class.new(2025) }

    it 'returns the neighbouring service years' do
      expect(service_year.previous).to eq(described_class.new(2024))
      expect(service_year.following).to eq(described_class.new(2026))
    end
  end
end
