# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::Location do
  let(:location) { create(:location) }

  it 'has a valid factory' do
    expect(location).to be_valid
  end

  it 'belongs to territory' do
    expect(location).to belong_to(:territory)
  end
end
