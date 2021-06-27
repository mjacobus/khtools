# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::Congregation, type: :model do
  subject(:congregation) { described_class.new }

  it 'is not local by default' do
    expect(congregation.local).to be(false)
  end

  it { is_expected.to validate_presence_of(:name) }
end
