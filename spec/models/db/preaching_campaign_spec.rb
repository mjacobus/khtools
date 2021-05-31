# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::PreachingCampaign, type: :model do
  subject(:campaign) { factories.preaching_campaigns.build }

  it  { is_expected.to validate_presence_of(:code) }
  it  { is_expected.to validate_uniqueness_of(:code).case_insensitive }
  it  { is_expected.to validate_presence_of(:name) }

  it 'has many assignments' do
    expect(campaign).to have_many(:assignments)
      .class_name('Db::PreachingCampaignAssignment')
      .inverse_of(:campaign)
      .dependent(:restrict_with_exception)
  end
end
