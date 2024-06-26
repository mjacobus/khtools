# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:factory) { factories.users }
  let(:user) { factory.build }

  it { is_expected.to belong_to(:account).class_name('Db::Account').optional }

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
