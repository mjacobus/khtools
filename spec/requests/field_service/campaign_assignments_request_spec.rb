# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FieldService::CampaignAssignments', type: :request do
  let(:described_class) { FieldService::CampaignAssignmentsController }
  let(:campaign) { assignment.campaign }
  let(:assignment) { factories.preaching_campaign_assignments.create }

  before do
    login_user(admin_user)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get field_service_campaign_assignments_path(campaign)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(campaign.name)
      expect(response.body).to include(assignment.assignee.name)
    end
  end
end
