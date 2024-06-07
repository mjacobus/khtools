# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::AccessToken do
  let(:territory) { factories.territories.create }
  let(:create) { described_class.for(territory) }

  it { is_expected.to validate_presence_of(:token) }
  it { is_expected.to validate_uniqueness_of(:token).case_insensitive }
  it { is_expected.to validate_presence_of(:resource) }
  it { is_expected.to validate_presence_of(:expires_at) }

  describe '.for' do
    it 'creates a new token' do
      freeze_time do
        expect { create }.to change(described_class, :count).by(1)

        last = described_class.last

        expect(last.resource).to eq("Db::RegularTerritory:#{territory.id}")
        expect(last.token.length).to eq(36)
        expect(last.expires_at).to eq(24.hours.from_now)
      end
    end
  end

  describe '#valid_for?' do
    it 'returns true when all is good' do
      expect(create).to be_valid_for(territory)
    end

    it 'returns false when record is expired' do
      token = create
      token.expires_at = 1.minute.ago

      expect(token).not_to be_valid_for(territory)
    end

    it 'returns false when record is something else' do
      expect(create).not_to be_valid_for(factories.territories.create)
    end
  end
end
