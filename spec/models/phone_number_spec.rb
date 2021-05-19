# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhoneNumber do
  subject(:number) { described_class.new('(55)987654321') }

  describe '#unformatted' do
    it 'returns only numbers' do
      expect(number.unformatted).to eq('55987654321')
    end
  end

  describe '#to_s' do
    it 'returns (xx) xxxx-xxxx format' do
      expect(number.to_s).to eq('(55) 98765-4321')
    end
  end
end
