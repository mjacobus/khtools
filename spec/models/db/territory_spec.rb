# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::Territory, type: :model do
  let(:factory) { factories.territories }

  it 'persists' do
    expect { factory.create }.to change(described_class, :count).by(1)
  end

  it 'requires name' do
    territory = factory.build

    expect { territory.name = nil }.to change(territory, :valid?).from(true).to(false)
  end

  describe '#name uniqueness' do
    it 'is scopped to type' do
      factory.create(name: 'SomeName')
      territory = factory.build

      expect { territory.name = 'Somename' }.to change(territory, :valid?).from(true).to(false)
    end

    it 'accepts the same name if types are different' do
      factory.create(name: 'SomeName')
      territory = described_class.new(name: 'Somename')

      expect { territory.save! }.to change(described_class, :count).by(1)
    end
  end

  it 'has an assignee' do
    publisher = factories.publishers.create
    territory = factory.create(assignee: publisher)

    expect(territory.assignee).to eq(publisher)
  end

  describe '#search' do
    let(:banana) { factory.create(name: 'A Banana Territory') }
    let(:apple) { factory.create(name: 'An apple Territory') }
    let(:pineapple) { factory.create(name: 'A Pineapple Territory') }

    before do
      [banana, apple, pineapple]
    end

    it 'searches by name' do
      found = described_class.search(name: 'apple')

      expect(found.pluck(:name)).to eq([
        'An apple Territory',
        'A Pineapple Territory'
      ])
    end

    it 'search by name is sqli safe' do
      found = described_class.search(name: 'apple " or 1=1 --')
      expect(found.count).to be_zero

      found = described_class.search(name: "apple ' or 1=1 --")
      expect(found.count).to be_zero
    end

    context 'when searching by assignee' do
      let(:publisher) { factories.publishers.create }

      before do
        described_class.delete_all
        factory.create(assignee_id: publisher.id, name: 'assigned')
        factory.create(assignee_id: nil, name: 'unassigned')
      end

      it 'searches by assignee' do
        found = described_class.search(publisher_id: publisher.id.to_s)
        expect(found.map(&:name)).to eq(['assigned'])
      end

      it 'searches unassigned territories' do
        found = described_class.search(publisher_id: 'none')
        expect(found.map(&:name)).to eq(['unassigned'])
      end
    end
  end
end
