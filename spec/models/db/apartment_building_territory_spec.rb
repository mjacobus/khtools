# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::ApartmentBuildingTerritory, type: :model do
  let(:factory) { factories.apartment_building_territories }
  let(:territory) { factory.build }

  it 'persists' do
    expect { territory.save! }.to change(described_class, :count).by(1)
  end
end
