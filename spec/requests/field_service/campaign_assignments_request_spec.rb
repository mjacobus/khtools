# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers:
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

  describe 'POST #create_assignments' do
    let(:service) { instance_double(FieldService::CampaignAssignmentService) }

    before do
      allow(FieldService::CampaignAssignmentService).to receive(:new).and_return(service)
      allow(service).to receive(:create)
    end

    it 'creates assignments' do
      post create_field_service_campaign_assignments_url(campaign, territory_type: 'foo_bar')

      expect(service).to have_received(:create)
        .with(campaign_id: campaign.id.to_s, territory_type: 'foo_bar')

      expect(response).to redirect_to(field_service_campaign_assignments_url(campaign))
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
# rubocop:enable RSpec/MultipleMemoizedHelpers:
