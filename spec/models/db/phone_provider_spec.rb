# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::PhoneProvider, type: :model do
  it 'persists' do
    expect { factories.phone_providers.create }.to change(described_class, :count).by(1)
  end

  describe '#destroy' do
    it 'is restricted when record has territories' do
      provider = factories.phone_list_territories.create.phone_provider

      expect { provider.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end
end
