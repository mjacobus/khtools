# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::Publisher do
  let(:klass) { described_class }

  it 'persists' do
    klass.create!(name: 'John Doe', gender: 'm')

    expect(klass.count).to be 1
  end
end
