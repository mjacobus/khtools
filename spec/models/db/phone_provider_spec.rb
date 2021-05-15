# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::PhoneProvider, type: :model do
  it 'persists' do
    expect { factories.phone_providers.create }.to change(described_class, :count).by(1)
  end
end
