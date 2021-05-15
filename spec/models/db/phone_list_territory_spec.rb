# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::PhoneListTerritory, type: :model do
  let(:factory) { factories.phone_list_territories }

  it 'persists' do
    expect { factory.create }.to change(described_class, :count).by(1)
  end
end
