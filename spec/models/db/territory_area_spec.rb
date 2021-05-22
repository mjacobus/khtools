# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::TerritoryArea, type: :model do
  let(:factory) { factories.territory_areas }

  it 'persists' do
    expect { described_class.create!(name: 'foo') }
      .to change(described_class, :count).by(1)
  end

  it 'validates uniqueness of #name' do
    factory.create(name: 'SomeName')
    territory = factory.build

    expect { territory.name = 'Somename' }.to change(territory, :valid?).from(true).to(false)
  end
end
