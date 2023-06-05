# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territories::RegularTerritoriesController, type: :request do
  let(:factory) { factories.territories }
  let(:territory_params) do
    factory.attributes(
      name: 'new name'
    )
  end

  before do
    login_user(admin_user)
  end

  describe 'GET #index' do
    it 'returns http success' do
      territory = factories.territories.create(account: current_account)
      other = factories.commercial_territories.create

      get '/territories/regular_territories'

      expect(response).to have_http_status(:success)
      expect(response.body).to match(territory.name)
      expect(response.body).not_to match(other.name)
    end
  end

  describe 'GET #show' do
    let(:territory) { factories.territories.create }
    let(:perform_request) { get "/territories/regular_territories/#{territory.id}" }

    it 'returns http success' do
      perform_request

      expect(response).to have_http_status(:success)
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = Territories::ShowPageComponent.new(territory: territory)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'GET #public_show' do
    let(:territory) { factories.territories.create }

    before do
      login_user(nil)
    end

    context 'when token is valid' do
      let(:perform_request) do
        get "/territories/regular_territories/#{territory.id}/token/#{territory.public_view_token}"
      end

      it 'returns http success' do
        perform_request

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #create' do
    let(:params) { { territory: territory_params } }

    let(:perform_request) do
      post('/territories/regular_territories', params: params)
    end

    context 'when payload is valid' do
      it 'redirects to index' do
        perform_request

        expect(response).to redirect_to('/territories/regular_territories')
      end

      it 'creates record' do
        expect { perform_request }.to change(Db::RegularTerritory, :count).by(1)
      end
    end

    context 'when payload is invalid' do
      let(:params) { { territory: { name: '' } } }

      it 'returns status 422' do
        perform_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders form' do
        mock_renderer

        perform_request

        new_territory = Db::RegularTerritory.new(name: '', account: current_account)
        expected_component = Territories::FormPageComponent.new(territory: new_territory)
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  describe 'PATCH #update' do
    let(:territory) { factory.create }
    let(:params) { { territory: territory_params } }

    let(:perform_request) do
      patch("/territories/regular_territories/#{territory.id}", params: params)
    end

    context 'when payload is valid' do
      it 'redirects to index' do
        perform_request

        expect(response).to redirect_to('/territories/regular_territories')
      end

      it 'creates record' do
        expect { perform_request }.to change { territory.reload.name }.to('new name')
      end
    end

    context 'when payload is invalid' do
      let(:params) { { territory: { name: '' } } }

      it 'renders status 422' do
        perform_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders form' do
        mock_renderer

        perform_request

        territory.name = ''
        territory.account = current_account
        expected_component = Territories::FormPageComponent.new(territory: territory)
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:territory) { factory.create }
    let(:perform_request) { delete("/territories/regular_territories/#{territory.id}") }

    before do
      territory
    end

    it 'redirects to index' do
      perform_request

      expect(response).to redirect_to('/territories/regular_territories')
    end

    it 'deletes record' do
      expect { perform_request }.to change(Db::RegularTerritory, :count).by(-1)
    end
  end
end
