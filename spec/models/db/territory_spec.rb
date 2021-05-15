# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::Territory, type: :model do
  let(:factory) { factories.territories }

  it 'persists a territory' do
    expect { factory.create }.to change(described_class, :count).by(1)
  end

  it 'requires name' do
    territory = factory.build

    expect { territory.name = nil }.to change(territory, :valid?).from(true).to(false)
  end

  it 'validates uniqueness of name' do
    factory.create(name: 'SomeName')
    territory = factory.build

    expect { territory.name = 'Somename' }.to change(territory, :valid?).from(true).to(false)
  end

  it 'has an assignee' do
    publisher = factories.publishers.create
    territory = factory.create(assignee: publisher)

    expect(territory.assignee).to eq(publisher)
  end
end
