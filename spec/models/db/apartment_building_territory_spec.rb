# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::ApartmentBuildingTerritory, type: :model do
  subject(:territory) { factory.build }

  let(:factory) { factories.apartment_building_territories }

  it { is_expected.to validate_presence_of(:address) }
  it { is_expected.to belong_to(:area).class_name('Db::TerritoryArea').optional }

  it {
    expect(territory).to belong_to(:primary_preaching_method)
      .class_name('Db::PreachingMethod').optional
  }

  it {
    expect(territory).to belong_to(:secondary_preaching_method)
      .class_name('Db::PreachingMethod').optional
  }

  it {
    expect(territory).to belong_to(:tertiary_preaching_method)
      .class_name('Db::PreachingMethod').optional
  }

  it {
    expect(territory).to belong_to(:intercom_type)
      .class_name('Db::IntercomType').optional
  }

  it {
    expect(territory).to belong_to(:letter_box_type)
      .class_name('Db::LetterBoxType').optional
  }

  it 'has #apartments' do
    territory.apartments = <<~STR
      201, 202,
      203
      204,
    STR

    expect(territory.parsed_apartments).to eq(%w[201 202 203 204])
  end
end
