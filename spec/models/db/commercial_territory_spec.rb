# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::CommercialTerritory do
  subject(:territory) { factories.commercial_territories.build }

  it 'has and many contacts' do
    expect(territory).to have_and_belong_to_many(:contacts)
      .class_name('Db::Contact')
      .with_foreign_key(:territory_id)
      .dependent(:restrict_with_exception)
  end

  describe '#contacts' do
    let(:c1) { factories.contacts.create }
    let(:c2) { factories.contacts.create }

    before do
      territory.save!
      territory.contacts << c1
      territory.contacts << c2
    end

    it 'can be persisted' do
      expect(territory.reload.contacts.pluck(:id).sort).to eq([c1.id, c2.id])
    end

    it 'can be deleted' do
      territory.contacts.delete(c2.id)

      expect(territory.reload.contacts.pluck(:id).sort).to eq([c1.id])
    end
  end
end
