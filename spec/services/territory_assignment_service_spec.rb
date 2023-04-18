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
      expect(territory.assignee_id).to eq(last.assignee_id)
      expect(territory.assigned_at).to eq(last.assigned_at)
    end
  end

  describe '#assign' do
    let(:territory) { factories.territories.create }
    let(:publisher) { factories.publishers.create }
    let(:campaign) { factories.preaching_campaigns.create }
    let(:assign) { service.assign(territory: territory, to: publisher) }

    it 'assigns publisher' do
      expect { assign }.to change { territory.reload.assignee }.from(nil).to(publisher)
    end

    it 'assigns sets assigned_at' do
      freeze_time do
        expect { assign }.to change { territory.assigned_at }.from(nil).to(Time.zone.now)
      end
    end

    it 'creates an assignment' do
      freeze_time do
        expect { assign }.to change(Db::TerritoryAssignment, :count).by(1)
      end
    end

    it 'sets last assignment' do
      freeze_time do
        expect { assign }.to change { territory.reload.last_assignment }
          .from(nil)
      end
    end

    it 'creates an assignment with correct publisher id' do
      assign

      expect(Db::TerritoryAssignment.last.assignee_id).to eq(publisher.id)
    end

    it 'optinally adds notes to assignment' do
      territory.assign_to(publisher, notes: 'foo')

      expect(Db::TerritoryAssignment.last.notes).to eq('foo')
    end

    it 'optinally adds campaign_id to assignment' do
      territory.assign_to(publisher, campaign: campaign.id)

      expect(Db::TerritoryAssignment.last.campaign_id).to eq(campaign.id)
    end

    it 'creates an assignment with correct timestamp' do
      freeze_time do
        assign

        expect(Db::TerritoryAssignment.last.assigned_at).to eq(Time.zone.now)
      end
    end

    it 'raises error if territory is already assigned' do
      assign

      expect do
        territory.assign_to(publisher)
      end.to raise_error(TerritoryAssignmentService::AssignmentError)
    end
  end
end
