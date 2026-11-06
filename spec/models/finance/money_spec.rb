# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::Money do
  describe '.format' do
    it { expect(described_class.format(cents: 15_000)).to eq('R$ 150,00') }
    it { expect(described_class.format(cents: 158_705)).to eq('R$ 1.587,05') }
    it { expect(described_class.format(cents: 0)).to eq('R$ 0,00') }
    it { expect(described_class.format(cents: 123_456_789)).to eq('R$ 1.234.567,89') }
  end

  describe '.parse' do
    {
      '150' => 15_000,
      '150,5' => 15_050,
      '1.587,05' => 158_705,
      'R$1.587,05' => 158_705,
      'R$ 74,49' => 7449
    }.each do |text, cents|
      it("parses #{text}") { expect(described_class.parse(text:)).to eq(cents) }
    end

    it('accepts a dot as decimal separator') {
      expect(described_class.parse(text: '120.50')).to eq(12_050)
    }

    it('accepts a one-digit dot decimal') { expect(described_class.parse(text: '1.5')).to eq(150) }

    %w[12,345 -50 10abc 1.2.3].each do |text|
      it("rejects #{text} instead of truncating it") {
        expect(described_class.parse(text:)).to be_nil
      }
    end

    it('returns nil for garbage') { expect(described_class.parse(text: 'abc')).to be_nil }
    it('returns nil for blank') { expect(described_class.parse(text: '')).to be_nil }
  end
end
