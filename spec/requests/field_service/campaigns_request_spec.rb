# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FieldService::Campaigns', type: :request do
  let(:described_class) { FieldService::CampaignsController }
  let(:campaign) { factories.preaching_campaigns.create }

  before do
    login_user(admin_user)
    campaign
  end

  describe 'GET #index' do
    it 'responds with success' do
      get field_service_campaigns_path

      expect(response).to be_successful
      expect(response.body).to include(campaign.name)
    end
  end
end
