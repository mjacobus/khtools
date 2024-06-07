# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::RegularTerritory do
  let(:factory) { factories.territories }

  it 'persists' do
    expect { factory.create }.to change(described_class, :count).by(1)
  end
end
