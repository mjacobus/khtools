# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:factory) { factories.users }
  let(:user) { factory.build }

  it 'persists' do
    expect { user.save! }.to change(User, :count).by(1)
  end
end
