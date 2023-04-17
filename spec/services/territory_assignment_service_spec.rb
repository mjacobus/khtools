# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TerritoryAssignmentService do
  subject(:service) { described_class.new }

  describe '#update_last_assignment' do
    let(:territory) { factories.territories.create }
    let(:first) do
      factories.territory_assignments.create(territory: territory, assigned_at: 2.days.ago)
    end
    let(:last) do
      factories.territory_assignments.create(territory: territory, assigned_at: 2.hours.ago)
    end

    before do
      first
      last
    end

    it 'updates last assignment' do
      service.update_last_assignment(territory: territory)

      expect(territory.last_assignment_id).to eq(last.id)
      expect(territory.last_assignment).to eq(last)
    end
  end
end
