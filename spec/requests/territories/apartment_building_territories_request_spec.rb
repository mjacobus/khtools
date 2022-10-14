# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territories::ApartmentBuildingTerritoriesController, type: :request do
  let(:factory) { factories.apartment_building_territories }
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
      territory = factories.apartment_building_territories.create(account: current_account)
      other = factories.phone_list_territories.create

      login_user(admin_user)
      get '/territories/apartment_building_territories'

      expect(response).to have_http_status(:success)
      expect(response.body).to match(territory.name)
      expect(response.body).not_to match(other.name)
    end
  end

  describe 'POST #create' do
    let(:params) { { territory: territory_params } }

    let(:perform_request) do
      post('/territories/apartment_building_territories', params: params)
    end

    context 'when payload is valid' do
      it 'redirects to index' do
        perform_request

        expect(response).to redirect_to('/territories/apartment_building_territories')
      end

      it 'creates record' do
        expect { perform_request }.to change(Db::ApartmentBuildingTerritory, :count).by(1)
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

        new_territory = Db::ApartmentBuildingTerritory.new(name: '', account_id: current_account.id)
        expected_component = Territories::FormPageComponent.new(territory: new_territory)
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  describe 'PATCH #update' do
    let(:territory) { factory.create }
    let(:params) { { territory: territory_params } }

    let(:perform_request) do
      patch("/territories/apartment_building_territories/#{territory.id}", params: params)
    end

    context 'when payload is valid' do
      it 'redirects to index' do
        perform_request

        expect(response).to redirect_to('/territories/apartment_building_territories')
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
        territory.account_id = current_account.id
        expected_component = Territories::FormPageComponent.new(territory: territory)
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:territory) { factory.create }
    let(:perform_request) { delete("/territories/apartment_building_territories/#{territory.id}") }

    before do
      territory
    end

    it 'redirects to index' do
      perform_request

      expect(response).to redirect_to('/territories/apartment_building_territories')
    end

    it 'deletes record' do
      expect { perform_request }.to change(Db::ApartmentBuildingTerritory, :count).by(-1)
    end
  end
end
