# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:factory) { factories.users }
  let(:user) { factory.build }

  it { is_expected.to belong_to(:account).class_name('Db::Account').optional }

  describe 'account change' do
    let(:account) { factories.accounts.create }
    let(:user) { factory.create(account:) }

    it 'is allowed when the user is not linked to a publisher' do
      user.account = factories.accounts.create

      expect(user).to be_valid
    end

    it 'is rejected while the user is linked to a publisher of the current account' do
      factories.publishers.create(account:, user:)

      user.account = factories.accounts.create

      expect(user).not_to be_valid
      expect(user.errors[:account]).to be_present
    end
  end

  describe '.linkable_to' do
    let(:account) { factories.accounts.create }
    let(:publisher) { factories.publishers.create(account:) }

    it 'excludes users linked to another publisher' do
      free = factory.create(account:)
      factories.publishers.create(account:, user: factory.create(account:))

      expect(account.users.linkable_to(publisher)).to eq([free])
    end

    it 'includes the user linked to the given publisher' do
      user = factory.create(account:)
      publisher.update!(user:)

      expect(account.users.linkable_to(publisher)).to eq([user])
    end
  end

  describe '#permissions' do
    it 'is initially an empty hash' do
      user.permissions_config = ''

      expect(user.permissions).to eq('controllers' => [])
    end

    it 'returns a hash containing the configuration' do
      user.permissions_config = '{"foo":"bar"}'

      expect(user.permissions).to eq({ 'controllers' => [], 'foo' => 'bar' })
    end

    it 'can be retrieved after persistency' do
      user.permissions_config = '{"foo":"bar"}'
      user.save!

      expect(user.permissions).to eq({ 'controllers' => [], 'foo' => 'bar' })
    end

    it 'can be assigned by #add_permission' do
      user.grant_controller_access('foo')
      user.grant_controller_access('bar', action: 'index')
      user.save!

      expected = { 'controllers' => ['foo#*', 'bar#index'] }

      expect(user.permissions).to eq(expected)
      expect(user.reload.permissions).to eq(expected)
    end
  end

  describe '#controller_accesses' do
    it 'can be assigned by #controller_accesses=' do
      user.controller_accesses = (['foo#bar'])
      user.controller_accesses = (['foo#bar', '#'])
      user.save!

      expected = { 'controllers' => ['foo#bar'] }

      expect(user.permissions).to eq(expected)
      expect(user.reload.permissions).to eq(expected)
      expect(user.controller_accesses).to eq(['foo#bar'])
    end
  end
end
