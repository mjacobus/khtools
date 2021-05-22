# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::ApartmentBuildingTerritory, type: :model do
  let(:factory) { factories.apartment_building_territories }
  let(:territory) { factory.build }

  # it { is_expected.to validate_presence_of(:number_of_apartments) }
  it { is_expected.to validate_presence_of(:address) }
  it { is_expected.to belong_to(:area).class_name('Db::TerritoryArea').optional }
  # it { is_expected.to validate_inclusion_of(:primary_preaching_method)
  #   .in_array(%w[letters intercom]) }
  # it { is_expected.to validate_inclusion_of(:secondary_preaching_method)
  #   .in_array(%w[letters intercom]) }
  # it { is_expected.to validate_inclusion_of(:tertiary_preaching_method)
  #   .in_array(%w[letters intercom]) }
  # it { is_expected.to validate_inclusion_of(:letter_box_type)
  #   .in_array(%w[letters intercom]) }
  # it { is_expected.to validate_inclusion_of(:intercom_type)
  #   .in_array(%w[letters intercom]) }
end
