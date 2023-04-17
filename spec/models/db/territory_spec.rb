# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::Territory, type: :model do
  subject(:territory) { factory.build }

  let(:factory) { factories.territories }

  it {
    expect(territory).to have_many(:assignments)
      .class_name('Db::TerritoryAssignment')
      .dependent(:restrict_with_exception)
  }

  it { is_expected.to belong_to(:account).class_name('Db::Account') }
  it { is_expected.to belong_to(:field_service_group).class_name('Db::FieldServiceGroup').optional }

  it 'persists' do
    expect { factory.create }.to change(described_class, :count).by(1)
  end

  it 'requires name' do
    territory = factory.build

    expect { territory.name = nil }.to change(territory, :valid?).from(true).to(false)
  end

  describe '#name uniqueness' do
    it 'is scopped to type' do
      t1 = factory.create(name: 'SomeName')
      territory = factory.build(account: t1.account)

      expect { territory.name = 'Somename' }.to change(territory, :valid?).from(true).to(false)
    end

    it 'accepts the same name if types are different' do
      factory.create(name: 'SomeName')
      territory = factory.build(name: 'Somename')

      expect { territory.save! }.to change(described_class, :count).by(1)
    end

    it 'accepts the same name and type if account is different' do
      account = factories.accounts.create
      factory.create(name: 'SomeName') # regular territory
      territory = factory.build(name: 'Somename', account: account)

      expect { territory.save! }.to change(described_class, :count).by(1)
    end
  end

  it 'has an assignee' do
    publisher = factories.publishers.create
    territory = factory.create(assignee: publisher)

    expect(territory.assignee).to eq(publisher)
  end

  describe '#search by name' do
    let(:banana) { factory.create(name: 'A Banana Territory') }
    let(:apple) { factory.create(name: 'An apple Territory') }
    let(:pineapple) { factory.create(name: 'A Pineapple Territory') }

    before do
      [banana, apple, pineapple]
    end

    it 'searches by name' do
      found = described_class.search(name: 'apple')

      expect(found.pluck(:name)).to eq([
        'An apple Territory',
        'A Pineapple Territory'
      ])
    end

    it 'search by name is sqli safe' do
      found = described_class.search(name: 'apple " or 1=1 --')
      expect(found.count).to be_zero

      found = described_class.search(name: "apple ' or 1=1 --")
      expect(found.count).to be_zero
    end
  end

  describe '#search by assignee' do
    context 'when searching by assignee' do
      let(:publisher) { factories.publishers.create }

      before do
        described_class.delete_all
        factory.create(assignee_id: publisher.id, name: 'assigned')
        factory.create(assignee_id: nil, name: 'unassigned')
      end

      it 'searches by assignee' do
        found = described_class.search(publisher_id: publisher.id.to_s)
        expect(found.map(&:name)).to eq(['assigned'])
      end

      it 'searches unassigned territories' do
        found = described_class.search(publisher_id: 'none')
        expect(found.map(&:name)).to eq(['unassigned'])
      end
    end
  end

  describe '#search by area' do
    let(:area) { factories.territory_areas.create }

    before do
      described_class.delete_all
      factory.create(area_id: area.id, name: 'expected')
      factory.create(area_id: nil, name: 'unexpected')
    end

    it 'returns expected territories' do
      found = described_class.search(area_id: area.id.to_s)
      expect(found.map(&:name)).to eq(['expected'])
    end
  end

  describe '#search by territory_id' do
    let(:territory) { factories.territories.create }

    before do
      described_class.delete_all
      factory.create(territory_id: territory.id, name: 'expected')
      factory.create(territory_id: nil, name: 'unexpected')
    end

    it 'returns expected territories' do
      found = described_class.search(territory_id: territory.id.to_s)
      expect(found.map(&:name)).to eq(['expected'])
    end
  end

  describe '#search by preaching method' do
    let(:method) { factories.preaching_methods.create }

    before do
      described_class.delete_all
      factory.create(primary_preaching_method_id: method.id, name: 'expected1')
      factory.create(secondary_preaching_method_id: method.id, name: 'expected2')
      factory.create(tertiary_preaching_method_id: method.id, name: 'expected3')
      factory.create(
        primary_preaching_method_id: nil,
        secondary_preaching_method_id: nil,
        tertiary_preaching_method_id: nil,
        name: 'unexpected1'
      )
    end

    it 'returns expected territories' do
      found = described_class.search(preaching_method_id: method.id.to_s)
      expect(found.map(&:name)).to eq(%w[expected1 expected2 expected3])
    end

    it 'keeps other criterias' do
      found = described_class.search(preaching_method_id: method.id.to_s, name: 'ted1')
      expect(found.map(&:name)).to eq(%w[expected1])
    end
  end

  describe '#search by pending_verification' do
    before do
      described_class.delete_all
      factory.create(pending_verification: true, name: 'pending')
      factory.create(pending_verification: false, name: 'ok')
      factory.create(pending_verification: nil, name: 'maybe')
    end

    it 'returns expected territories' do
      found = described_class.search(pending_verification: 'true')
      expect(found.map(&:name)).to eq(['pending'])

      found = described_class.search(pending_verification: 'false')
      expect(found.map(&:name)).to eq(['ok'])
    end
  end

  describe '#assign_to' do
    subject(:territory) { factory.create }

    let(:publisher) { factories.publishers.create }
    let(:campaign) { factories.preaching_campaigns.create }
    let(:assign) { territory.assign_to(publisher) }

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

  describe '#return' do
    subject(:territory) { factory.create }

    let(:publisher) { factories.publishers.create }

    it 'resets assignment fields' do
      territory.assign_to(publisher)
      territory.return

      expect(territory.assignee).to be_nil
      expect(territory.assigned_at).to be_nil
    end

    it 'markes assignments as returned' do
      assignment = territory.assign_to(publisher)
      other_assignment = factory.create.assign_to(publisher)

      territory.return
      territory.return # yes, twice

      expect(assignment.reload).to be_returned
      expect(other_assignment.reload).not_to be_returned
    end
  end

  it 'has static_map_zoom' do
    expect do
      territory.static_map_zoom = 'foo'
    end.to change {
      territory.static_map_zoom
    }.from(nil).to('foo')
  end

  it 'has static_map_scale' do
    expect do
      territory.static_map_scale = 'foo'
    end.to change {
      territory.static_map_scale
    }.from(nil).to('foo')
  end

  it 'has static_map_size' do
    expect do
      territory.static_map_size = 'foo'
    end.to change {
      territory.static_map_size
    }.from(nil).to('foo')
  end

  it 'has static_map_center' do
    expect do
      territory.static_map_center = 'foo'
    end.to change {
      territory.static_map_center
    }.from(nil).to('foo')
  end
end
