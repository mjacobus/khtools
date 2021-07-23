# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territories::PhoneListTerritoriesController, type: :request do
  let(:factory) { factories.phone_list_territories }
  let(:territory_params) do
    factory.attributes(
      name: 'new name',
      phone_provider_id: factories.phone_providers.create.id
    )
  end

  before do
    login_user(admin_user)
  end

  describe 'GET #index' do
    it 'returns http success' do
      territory = factory.create
      other = factories.territories.create

      get '/territories/phone_list_territories'

      expect(response).to have_http_status(:success)
      expect(response.body).to match(territory.name)
      expect(response.body).not_to match(other.name)
    end
  end

  describe 'POST #create' do
    let(:params) { { territory: territory_params } }

    let(:perform_request) do
      post('/territories/phone_list_territories', params: params)
    end

    context 'when payload is valid' do
      it 'redirects to index' do
        perform_request

        expect(response).to redirect_to('/territories/phone_list_territories')
      end

      it 'creates record' do
        expect { perform_request }.to change(Db::Territory, :count).by(1)
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

        new_territory = Db::PhoneListTerritory.new(name: '')
        expected_component = Territories::FormPageComponent.new(territory: new_territory)
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  describe 'PATCH #update' do
    let(:territory) { factory.create }
    let(:params) { { territory: territory_params } }

    let(:perform_request) do
      patch("/territories/phone_list_territories/#{territory.id}", params: params)
    end

    context 'when payload is valid' do
      it 'redirects to index' do
        perform_request

        expect(response).to redirect_to('/territories/phone_list_territories')
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
        expected_component = Territories::FormPageComponent.new(territory: territory)
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:territory) { factory.create }
    let(:perform_request) { delete("/territories/phone_list_territories/#{territory.id}") }

    before do
      territory
    end

    it 'redirects to index' do
      perform_request

      expect(response).to redirect_to('/territories/phone_list_territories')
    end

    it 'deletes record' do
      expect { perform_request }.to change(Db::PhoneListTerritory, :count).by(-1)
    end
  end
end
