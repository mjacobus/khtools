# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territories::PhoneListTerritoriesController, type: :request do
  let(:factory) { factories.phone_list_territories }
  let(:territory_params) { factory.attributes(name: 'new name') }

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

  describe 'PATCH #update' do
    let(:territory) { factory.create }
    let(:params) { { territory: territory_params } }

    let(:perform_request) do
      patch("/territories/phone_list_territories/#{territory.id}", params: params)
    end

    context 'when payload is valid' do
      it 'responds with 422' do
        perform_request

        expect(response).to redirect_to('/territories/phone_list_territories')
      end

      it 'creates record' do
        expect { perform_request }.to change { territory.reload.name }.to('new name')
      end
    end

    context 'when payload is invalid' do
      let(:params) { { territory: { name: '' } } }

      it 'returns with success' do
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
end
