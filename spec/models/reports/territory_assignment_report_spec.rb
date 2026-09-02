# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reports::TerritoryAssignmentReport do
  subject(:report) { described_class.new(account:, service_year:, type: Db::RegularTerritory) }

  # 2025-09-01 .. 2026-08-31
  let(:service_year) { ServiceYear.new(2025) }
  let(:account) { factories.accounts.create }
  let(:publisher) { factories.publishers.create(account:, name: 'João') }
  let(:territory) { factories.territories.create(account:, name: '1') }

  def assign(territory:, assigned_at:, returned_at: nil, assignee: publisher)
    factories.territory_assignments.create(territory:, assignee:, assigned_at:, returned_at:)
  end

  def row_for(territory)
    report.rows.find { |row| row.territory == territory }
  end

  describe '#rows' do
    it 'returns one row per territory, even without assignments' do
      territory

      expect(report.rows.map(&:territory)).to eq([territory])
      expect(report.rows.first.assignments).to eq([])
    end

    it 'only includes territories of the given account' do
      territory
      other = factories.territories.create(name: '2')

      expect(report.rows.map(&:territory)).to eq([territory])
      expect(report.rows.map(&:territory)).not_to include(other)
    end

    it 'only includes territories of the given type' do
      territory
      commercial = factories.commercial_territories.create(account:, name: '2')

      expect(report.rows.map(&:territory)).to eq([territory])
      expect(report.rows.map(&:territory)).not_to include(commercial)
    end

    it 'includes every type when no type is given' do
      regular = territory
      commercial = factories.commercial_territories.create(account:, name: '2')
      report = described_class.new(account:, service_year:, type: nil)

      expect(report.rows.map(&:territory)).to eq([regular, commercial])
    end

    it 'sorts territories numerically instead of alphabetically' do
      ten = factories.territories.create(account:, name: '10')
      two = factories.territories.create(account:, name: '2')
      one = territory

      expect(report.rows.map { |row| row.territory.name }).to eq(%w[1 2 10])
      expect(report.rows.map(&:territory)).to eq([one, two, ten])
    end

    it 'sorts mixed names naturally' do
      factories.territories.create(account:, name: 'B-2')
      factories.territories.create(account:, name: 'B-10')
      factories.territories.create(account:, name: 'A-1')
      territory

      expect(report.rows.map { |row| row.territory.name }).to eq(%w[1 A-1 B-2 B-10])
    end
  end

  describe '#rows assignments (overlap with the service year)' do
    it 'includes an assignment that starts and ends within the period' do
      assignment = assign(territory:, assigned_at: '2025-10-01', returned_at: '2025-11-01')

      expect(row_for(territory).assignments).to eq([assignment])
    end

    it 'includes an assignment that started before and ended within the period' do
      assignment = assign(territory:, assigned_at: '2025-07-01', returned_at: '2025-10-01')

      expect(row_for(territory).assignments).to eq([assignment])
    end

    it 'includes an assignment that started within and ends after the period' do
      assignment = assign(territory:, assigned_at: '2026-08-01', returned_at: '2026-10-01')

      expect(row_for(territory).assignments).to eq([assignment])
    end

    it 'includes an assignment that spans the whole period' do
      assignment = assign(territory:, assigned_at: '2025-01-01', returned_at: '2027-01-01')

      expect(row_for(territory).assignments).to eq([assignment])
    end

    it 'includes an open assignment made before the period' do
      assignment = assign(territory:, assigned_at: '2025-01-01', returned_at: nil)

      expect(row_for(territory).assignments).to eq([assignment])
    end

    it 'excludes an assignment that ended before the period' do
      assign(territory:, assigned_at: '2024-10-01', returned_at: '2024-11-01')

      expect(row_for(territory).assignments).to eq([])
    end

    it 'excludes an assignment that starts after the period' do
      assign(territory:, assigned_at: '2026-09-01', returned_at: nil)

      expect(row_for(territory).assignments).to eq([])
    end

    it 'orders assignments from the oldest to the newest' do
      second = assign(territory:, assigned_at: '2026-01-01', returned_at: '2026-02-01')
      first = assign(territory:, assigned_at: '2025-10-01', returned_at: '2025-11-01')
      third = assign(territory:, assigned_at: '2026-03-01')

      expect(row_for(territory).assignments).to eq([first, second, third])
    end

    it 'keeps assignments of each territory separate' do
      other = factories.territories.create(account:, name: '2')
      mine = assign(territory:, assigned_at: '2025-10-01')
      theirs = assign(territory: other, assigned_at: '2025-10-02')

      expect(row_for(territory).assignments).to eq([mine])
      expect(row_for(other).assignments).to eq([theirs])
    end
  end

  describe '#rows last_completed_at' do
    it 'is the most recent completion before the service year' do
      assign(territory:, assigned_at: '2023-01-01', returned_at: '2023-02-01')
      assign(territory:, assigned_at: '2024-01-01', returned_at: '2024-03-15')

      expect(row_for(territory).last_completed_at.to_date).to eq(Date.new(2024, 3, 15))
    end

    it 'ignores completions within the service year' do
      assign(territory:, assigned_at: '2024-01-01', returned_at: '2024-03-15')
      assign(territory:, assigned_at: '2025-10-01', returned_at: '2025-11-01')

      expect(row_for(territory).last_completed_at.to_date).to eq(Date.new(2024, 3, 15))
    end

    it 'ignores assignments that were never returned' do
      assign(territory:, assigned_at: '2024-01-01', returned_at: nil)

      expect(row_for(territory).last_completed_at).to be_nil
    end

    it 'is nil when the territory was never completed before' do
      territory

      expect(row_for(territory).last_completed_at).to be_nil
    end
  end

  describe '#columns_count' do
    it 'is four when no territory has more than four assignments' do
      3.times { |index| assign(territory:, assigned_at: "2025-10-0#{index + 1}") }

      expect(report.columns_count).to eq(4)
    end

    it 'grows to fit the territory with the most assignments' do
      6.times { |index| assign(territory:, assigned_at: "2025-10-0#{index + 1}") }

      expect(report.columns_count).to eq(6)
    end

    it 'is four when there are no territories at all' do
      expect(report.columns_count).to eq(4)
    end
  end

  describe '.available_service_years' do
    it 'spans from the oldest assignment to the current service year' do
      assign(territory:, assigned_at: '2023-10-01')

      travel_to(Date.new(2026, 2, 1)) do
        years = described_class.available_service_years(account).map(&:year)

        expect(years).to eq([2025, 2024, 2023])
      end
    end

    it 'is the current service year when there are no assignments' do
      travel_to(Date.new(2026, 2, 1)) do
        expect(described_class.available_service_years(account).map(&:year)).to eq([2025])
      end
    end

    it 'ignores assignments from other accounts' do
      assign(territory: factories.territories.create(name: 'other'), assigned_at: '2010-10-01')

      travel_to(Date.new(2026, 2, 1)) do
        expect(described_class.available_service_years(account).map(&:year)).to eq([2025])
      end
    end
  end

  describe '.type_for' do
    it 'resolves the known territory types' do
      expect(described_class.type_for('regular')).to eq(Db::RegularTerritory)
      expect(described_class.type_for('commercial')).to eq(Db::CommercialTerritory)
      expect(described_class.type_for('phone_list')).to eq(Db::PhoneListTerritory)
      expect(described_class.type_for('apartment_building'))
        .to eq(Db::ApartmentBuildingTerritory)
    end

    it 'returns nil for the "all types" key' do
      expect(described_class.type_for('all')).to be_nil
    end

    it 'falls back to regular territories for unknown values' do
      expect(described_class.type_for('Kernel')).to eq(Db::RegularTerritory)
      expect(described_class.type_for(nil)).to eq(Db::RegularTerritory)
    end
  end
end
