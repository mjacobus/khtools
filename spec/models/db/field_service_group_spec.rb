# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::FieldServiceGroup, type: :model do
  let(:factories) { TestFactories.new }
  let(:publishers) { factories.publishers }
  let(:groups) { factories.field_service_groups }
  let(:publisher_group) { factories.publishers.create.group }

  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to validate_presence_of(:name) }

  it 'can be persisted' do
    expect { groups.create }.to change(described_class, :count).by(1)
  end

  it 'has many publishers' do
    publisher = factories.publishers.create

    expect(publisher.group.publishers).to eq([publisher])
  end

  describe '#destroy' do
    it 'is restricted when group publishers' do
      group = publisher_group

      expect { group.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end

  it 'can be distroyed if group is empty' do
    group = groups.create

    expect { group.destroy }.to change(described_class, :count).by(-1)
  end
end
