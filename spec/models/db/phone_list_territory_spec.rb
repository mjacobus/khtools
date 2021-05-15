# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::PhoneListTerritory, type: :model do
  let(:factory) { factories.phone_list_territories }
  let(:territory) { factory.build }

  it 'persists' do
    expect { territory.save }.to change(described_class, :count).by(1)
  end

  it 'persists big numbers' do
    territory.initial_phone_number = 9_999_999_998
    territory.final_phone_number = 9_999_999_999

    expect { territory.save }.to change(described_class, :count).by(1)

    territory.reload

    expect(territory.initial_phone_number).to eq 9_999_999_998
    expect(territory.final_phone_number).to eq 9_999_999_999
  end

  it 'requires #initial_phone_number' do
    expect { territory.initial_phone_number = nil }
      .to change(territory, :valid?)
      .from(true).to(false)
  end

  it 'requires #final_phone_number' do
    expect { territory.final_phone_number = nil }
      .to change(territory, :valid?)
      .from(true).to(false)
  end

  it 'belongs to #phone_provider' do
    expect(territory.phone_provider).to be_a(Db::PhoneProvider)
  end
end
