# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FieldService::CampaignAssignments', type: :request do
  let(:described_class) { FieldService::CampaignAssignmentsController }
  let(:campaign) { assignment.campaign }
  let(:assignment) { factories.preaching_campaign_assignments.create }
  let(:publisher) { factories.publishers.create }
  let(:another_publisher) { factories.publishers.create }

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

  describe 'PATCH #update' do
    let(:perform_request) do
      patch field_service_campaign_assignment_path(campaign, assignment),
            params: { assignment: { assignee_id: another_publisher.id } }
    end

    it 'updates assignemnt' do
      publisher

      expect do
        perform_request
      end.to change { assignment.reload.assignee_id }.to(another_publisher.id)
    end

    it 'redirects to index page' do
      perform_request

      expect(response).to redirect_to(field_service_campaign_assignments_url(campaign))
    end
  end
end
