# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::Publisher, type: :model do
  let(:publisher) { factories.publishers.create }

  it 'persists' do
    publisher

    expect(described_class.count).to be 1
  end

  it 'belongs to a #group' do
    group = Db::FieldServiceGroup.create!(name: 'group')

    factories.publishers.create(group: group)

    expect(described_class.last.group).to eq(group)
  end

  describe '#destroy' do
    it 'is restricted when has territories' do
      factories.territories.create(assignee: publisher)

      expect { publisher.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end

  describe '.identify'
end
