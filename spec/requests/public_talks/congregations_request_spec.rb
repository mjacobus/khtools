# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicTalks::CongregationsController, type: :request do
  let(:congregation) { factories.congregations.create }

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

      expected_component = Congregations::IndexPageComponent.new(Db::Congregation.all)
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
    let(:congregation) { Db::Congregation.new }

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
    let(:perform_request) { post('/public_talks/congregations', params: params) }

    context 'when payload is valid' do
      let(:params) { { congregation: factories.congregations.attributes } }

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

        expected_component = Congregations::FormPageComponent.new(Db::Congregation.new(name: ''))
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
      patch("/public_talks/congregations/#{congregation.id}", params: params)
    end

    context 'when payload is valid' do
      let(:params) { { congregation: factories.congregations.attributes.merge(name: 'new name') } }

      it 'responds with 422' do
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
        mock_renderer

        perform_request

        congregation.name = ''
        expected_component = Congregations::FormPageComponent.new(congregation)
        expect(renderer).to have_rendered_component(expected_component)
      end
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
