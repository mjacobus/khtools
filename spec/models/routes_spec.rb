# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Routes do
  subject(:routes) { described_class.new }

  describe '#to' do
    it 'resolves publisher' do
      record = Db::Publisher.new(id: 1)

      expected = '/congregation/publishers/1'

      expect(routes.to(record)).to eq(expected)
    end

    it 'resolves territory path' do
      record = Db::CommercialTerritory.new(id: 1)

      expected = '/territories/commercial_territories/1'

      expect(routes.to(record)).to eq(expected)
    end
  end
end
