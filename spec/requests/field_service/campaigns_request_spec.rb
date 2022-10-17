# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FieldService::CampaignsController, type: :request do
  let(:campaign) { factories.preaching_campaigns.create(account: current_account) }
  let(:factory) { factories.preaching_campaigns }

  before do
    login_user(admin_user)
    campaign
  end

  describe 'GET #index' do
    let(:perform_request) { get routes.field_service_campaigns_path }

    it 'responds with success' do
      perform_request

      expect(response).to be_successful
      expect(response.body).to include(campaign.name)
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = FieldService::Campaigns::IndexPageComponent.new(
        campaigns: current_account.preaching_campaigns.order(created_at: :desc)
      )
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'GET #show' do
    let(:perform_request) { get(routes.field_service_campaign_path(campaign)) }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = FieldService::Campaigns::ShowPageComponent.new(
        campaign: campaign
      )
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'GET #new' do
    let(:perform_request) { get('/field_service/campaigns/new') }
    let(:campaign) { Db::PreachingCampaign.new }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      campaign.account = current_account

      expected_component = FieldService::Campaigns::FormPageComponent.new(
        campaign: campaign
      )
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'POST #create' do
    let(:perform_request) { post('/field_service/campaigns', params: params) }

    context 'when payload is valid' do
      let(:params) { { campaign: factory.attributes.merge(code: 'new code') } }

      it 'returns with success' do
        perform_request

        expect(response).to redirect_to('/field_service/campaigns')
      end

      it 'creates record' do
        expect { perform_request }.to change(Db::PreachingCampaign, :count).by(1)
      end
    end

    context 'when payload is invalid' do
      let(:params) { { campaign: { name: '' } } }

      it 'responds with 422' do
        perform_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders form' do
        mock_renderer

        perform_request

        expected_component = FieldService::Campaigns::FormPageComponent.new(
          campaign: Db::PreachingCampaign.new(name: '', account: current_account)
        )
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  describe 'GET #edit' do
    let(:perform_request) { get("/field_service/campaigns/#{campaign.id}/edit") }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = FieldService::Campaigns::FormPageComponent.new(campaign: campaign)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'PATCH #update' do
    let(:perform_request) do
      patch("/field_service/campaigns/#{campaign.id}", params: params)
    end

    context 'when payload is valid' do
      let(:params) do
        { campaign: factories.preaching_campaigns.attributes.merge(name: 'new name') }
      end

      it 'redirects to index' do
        perform_request

        expect(response).to redirect_to('/field_service/campaigns')
      end

      it 'creates record' do
        expect { perform_request }.to change { campaign.reload.name }.to('new name')
      end
    end

    context 'when payload is invalid' do
      let(:params) { { campaign: { name: '' } } }

      it 'returns with success' do
        perform_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders form' do
        mock_renderer

        perform_request

        campaign.name = ''
        expected_component = FieldService::Campaigns::FormPageComponent.new(
          campaign: campaign
        )
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:perform_request) { delete("/field_service/campaigns/#{campaign.id}") }

    it 'redirects to index' do
      perform_request

      expect(response).to redirect_to('/field_service/campaigns')
    end

    it 'deletes record' do
      expect { perform_request }.to change(Db::PreachingCampaign, :count).by(-1)
    end
  end
end
