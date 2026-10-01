# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicTalks::CongregationsController do
  let(:congregation) { factories.congregations.create(account: current_account) }
  let(:foreign_congregation) { factories.congregations.create }
  let(:attributes) { factories.congregations.attributes(account: current_account) }

  before do
    login_user(admin_user)

    congregation
  end

  describe 'GET #index' do
    let(:perform_request) { get('/public_talks/congregations') }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      congregations = current_account.congregations.order(:name)
      expected_component = Congregations::IndexPageComponent.new(congregations)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'GET #show' do
    let(:perform_request) { get("/public_talks/congregations/#{congregation.id}") }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = Congregations::ShowPageComponent.new(congregation)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'GET #new' do
    let(:perform_request) { get('/public_talks/congregations/new') }
    let(:congregation) { current_account.congregations.new }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = Congregations::FormPageComponent.new(congregation)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'POST #create' do
    let(:perform_request) { post('/public_talks/congregations', params:) }

    context 'when payload is valid' do
      let(:params) { { congregation: attributes } }

      it 'returns with success' do
        perform_request

        expect(response).to redirect_to('/public_talks/congregations')
      end

      it 'creates record' do
        expect { perform_request }.to change(Db::Congregation, :count).by(1)
      end
    end

    context 'when payload is invalid' do
      let(:params) { { congregation: { name: '' } } }

      it 'responds with 422' do
        perform_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders form' do
        mock_renderer

        perform_request

        congregation = current_account.congregations.new(name: '')
        expected_component = Congregations::FormPageComponent.new(congregation)
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  describe 'GET #edit' do
    let(:perform_request) { get("/public_talks/congregations/#{congregation.id}/edit") }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = Congregations::FormPageComponent.new(congregation)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'PATCH #update' do
    let(:perform_request) do
      patch("/public_talks/congregations/#{congregation.id}", params:)
    end

    context 'when payload is valid' do
      let(:params) do
        { congregation: attributes.merge(name: 'new name') }
      end

      it 'redirects to index' do
        perform_request

        expect(response).to redirect_to('/public_talks/congregations')
      end

      it 'creates record' do
        expect { perform_request }.to change { congregation.reload.name }.to('new name')
      end
    end

    context 'when payload is invalid' do
      let(:params) { { congregation: { name: '' } } }

      it 'returns with success' do
        perform_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders form' do
        skip 'TODO: Started failing comparison after rails upgrade to 7.1'
        mock_renderer

        perform_request

        congregation.name = ''
        expected_component = Congregations::FormPageComponent.new(congregation)
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  context 'when the congregation belongs to another congregation' do
    it 'is not listed' do
      get('/public_talks/congregations')

      expect(response.body).not_to include(foreign_congregation.name)
    end

    it 'is not shown' do
      get("/public_talks/congregations/#{foreign_congregation.id}")

      expect(response).to have_http_status(:not_found)
    end

    it 'is not deleted' do
      foreign_congregation

      expect { delete("/public_talks/congregations/#{foreign_congregation.id}") }
        .not_to change(Db::Congregation, :count)
    end
  end

  describe 'DELETE #destroy' do
    let(:perform_request) { delete("/public_talks/congregations/#{congregation.id}") }

    it 'redirects to index' do
      perform_request

      expect(response).to redirect_to('/public_talks/congregations')
    end

    it 'deletes record' do
      expect { perform_request }.to change(Db::Congregation, :count).by(-1)
    end
  end
end
