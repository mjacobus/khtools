# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::TerritoryArea do
  subject(:area) { factory.build }

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

  it 'has many territories' do
    expect(area).to have_many(:territories)
      .class_name('Db::Territory')
      .with_foreign_key(:area_id)
      .inverse_of(:area)
      .dependent(:restrict_with_exception)
  end
end
