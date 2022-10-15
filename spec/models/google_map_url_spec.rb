# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoogleMapUrl do
  subject(:url) { described_class.new(value) }

  let(:value) { 'https://www.google.com/maps/d/u/0/edit?mid=xyz&usp=sharing&ehbc=2E312F' }

  it 'converts to string' do
    expect(url.to_s).to eq(value)
  end

  it 'converts to embeddable' do
    result = url.embeddable

    expected = described_class.new('https://www.google.com/maps/d/u/0/embed?mid=xyz&usp=sharing&ehbc=2E312F')

    expect(result).to be_equal_to(expected)
  end

  it 'changes background' do
    result = url.with_background('#12FF55')

    expected = described_class.new('https://www.google.com/maps/d/u/0/edit?ehbc=12FF55&mid=xyz&usp=sharing')

    expect(result).to be_equal_to(expected)
  end

  it 'converts to editable' do
    result = url.embeddable.editable.to_s
    expect(result).to eq(value)
  end
end
