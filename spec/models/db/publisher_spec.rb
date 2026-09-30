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

  describe 'privileges' do
    it 'allows a brother to be an elder' do
      expect(factories.publishers.build(gender: 'm', elder: true)).to be_valid
    end

    it 'allows a brother to be a ministerial servant' do
      expect(factories.publishers.build(gender: 'm', ministerial_servant: true)).to be_valid
    end

    it 'allows a sister to be a pioneer' do
      expect(factories.publishers.build(gender: 'f', pioneer: true)).to be_valid
    end

    it 'does not allow a sister to be an elder' do
      publisher = factories.publishers.build(gender: 'f', elder: true)

      expect(publisher).not_to be_valid
      expect(publisher.errors[:elder]).to be_present
    end

    it 'does not allow a sister to be a ministerial servant' do
      publisher = factories.publishers.build(gender: 'f', ministerial_servant: true)

      expect(publisher).not_to be_valid
      expect(publisher.errors[:ministerial_servant]).to be_present
    end

    it 'reports each invalid privilege once for a sister' do
      publisher = factories.publishers.build(gender: 'f', elder: true, ministerial_servant: true)

      publisher.validate

      expect(publisher.errors.where(:ministerial_servant).size).to eq(1)
    end

    it 'does not allow being both elder and ministerial servant' do
      publisher = factories.publishers.build(gender: 'm', elder: true, ministerial_servant: true)

      expect(publisher).not_to be_valid
      expect(publisher.errors[:ministerial_servant]).to be_present
    end
  end

  describe '#privileges' do
    it 'is empty by default' do
      expect(factories.publishers.build.privileges).to eq([])
    end

    it 'lists the privileges held' do
      publisher = factories.publishers.build(elder: true, pioneer: true)

      expect(publisher.privileges).to eq(%i[elder pioneer])
    end
  end

  describe 'user' do
    let(:account) { factories.accounts.create }

    it 'is optional' do
      expect(factories.publishers.build(account:, user: nil)).to be_valid
    end

    it 'accepts a user from the same account' do
      user = factories.users.create(account:)

      expect(factories.publishers.build(account:, user:)).to be_valid
    end

    it 'rejects a user from another account' do
      user = factories.users.create
      publisher = factories.publishers.build(account:, user:)

      expect(publisher).not_to be_valid
      expect(publisher.errors[:user]).to be_present
    end

    it 'rejects a user already linked to another publisher' do
      user = factories.users.create(account:)
      factories.publishers.create(account:, user:)

      publisher = factories.publishers.build(account:, user:)

      expect(publisher).not_to be_valid
      expect(publisher.errors[:user]).to be_present
    end

    it 'is reachable from the user' do
      user = factories.users.create(account:)
      publisher = factories.publishers.create(account:, user:)

      expect(user.reload.publisher).to eq(publisher)
    end
  end

  describe '#destroy' do
    it 'is restricted when has territories' do
      factories.territories.create(assignee: publisher)

      expect { publisher.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end
end
