# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::Publisher do
  let(:publisher) { factories.publishers.create }

  it 'persists' do
    publisher

    expect(described_class.count).to be 1
  end

  it 'has many assignments' do
    expect(publisher).to have_many(:assignments)
      .class_name('Db::TerritoryAssignment')
      .inverse_of(:assignee)
      .dependent(:restrict_with_exception)
  end

  it { is_expected.to belong_to(:account).class_name('Db::Account') }

  it 'belongs to a #group' do
    group = factories.field_service_groups.create(name: 'group')

    factories.publishers.create(group:, account: group.account)

    expect(described_class.last.group).to eq(group)
  end

  describe 'group validation' do
    let(:account) { factories.accounts.create }

    it 'accepts a group from the same account' do
      group = factories.groups.create(account:)
      publisher = factories.publishers.build(account:, group:)

      expect(publisher).to be_valid
    end

    it 'rejects a group from another account' do
      group = factories.groups.create
      publisher = factories.publishers.build(account:, group:)

      expect(publisher).not_to be_valid
      expect(publisher.errors[:group]).to be_present
    end
  end

  describe '#destroy' do
    it 'is restricted when has territories' do
      factories.territories.create(assignee: publisher)

      expect { publisher.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end
end
