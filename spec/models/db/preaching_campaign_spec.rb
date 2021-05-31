# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::PreachingCampaign, type: :model do
  subject(:campaign) { factories.preaching_campaigns.build }

  it  { is_expected.to validate_presence_of(:code) }
  it  { is_expected.to validate_uniqueness_of(:code).case_insensitive }
  it  { is_expected.to validate_presence_of(:name) }
end
