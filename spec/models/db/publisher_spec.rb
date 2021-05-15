# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::Publisher, type: :model do
  let(:factories) { TestFactories.new }
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
end
