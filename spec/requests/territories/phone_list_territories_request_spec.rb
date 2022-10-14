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

  let(:token) { Db::AccessToken.for(territory) }
  let(:territory) { factory.create }

  describe 'GET #xls' do
    it 'returns http success when user is logged in' do
      login_user(admin_user)

      get "/territories/phone_list_territories/#{territory.id}/xls"

      expect(response).to have_http_status(:success)
      expect(response.headers['Content-Type']).to eq('application/octet-stream')
      expect(response.headers['Content-Disposition']).to match(/^attachment/)
      expect(response.headers['Content-Disposition']).to match(/filename="#{territory.name}.xls"/)
    end

    it 'returns http success access token is valid' do
      get "/territories/phone_list_territories/#{territory.id}/xls",
          params: { access_token: token.token }

      expect(response).to have_http_status(:success)
    end

    it 'responds with :not_found when token expired' do
      token.expires_at = 1.minute.ago
      token.save!

      get "/territories/phone_list_territories/#{territory.id}/xls",
          params: { access_token: token.token }

      expect(response).to have_http_status(:not_found)
    end

    it 'redirects when no access token or logged in user' do
      get "/territories/phone_list_territories/#{territory.id}/xls"

      expect(response).to redirect_to('/')
    end
  end

  describe 'DELETE #destroy' do
    let(:perform_request) do
      delete("/territories/phone_list_territories/#{territory.id}",
             params: { access_token: token.token })
    end

    it 'does not delete a record, even with a token' do
      territory

      expect { perform_request }.not_to change(Db::PhoneListTerritory, :count)
    end
  end

  describe 'GET #pdf' do
    it 'returns http success when user is logged in' do
      login_user(admin_user)

      get "/territories/phone_list_territories/#{territory.id}/pdf"

      expect(response).to have_http_status(:success)
      expect(response.headers['Content-Type']).to eq('application/pdf')
      expect(response.headers['Content-Disposition']).to match(/filename="#{territory.name}.pdf"/)
      expect(response.headers['Content-Disposition']).not_to match(/^attachment/)
    end

    it 'returns http success access token is valid' do
      get "/territories/phone_list_territories/#{territory.id}/pdf",
          params: { access_token: token.token }

      expect(response).to have_http_status(:success)
      expect(response.headers['Content-Type']).to eq('application/pdf')
      expect(response.headers['Content-Disposition']).to match(/filename="#{territory.name}.pdf"/)
      expect(response.headers['Content-Disposition']).to match(/^attachment/)
    end

    it 'responds with :not_found when token expired' do
      token.expires_at = 1.minute.ago
      token.save!

      get "/territories/phone_list_territories/#{territory.id}/pdf",
          params: { access_token: token.token }

      expect(response).to have_http_status(:not_found)
    end

    it 'redirects when no access token or logged in user' do
      get "/territories/phone_list_territories/#{territory.id}/pdf"

      expect(response).to redirect_to('/')
    end
  end

  context 'when logged in' do
    before do
      login_user(admin_user)
    end

    describe 'GET #index' do
      it 'returns http success' do
        territory = factory.create(account: current_account)
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

          new_territory = Db::PhoneListTerritory.new(name: '', account_id: current_account.id)
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
          territory.account = current_account
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

    describe 'POST #create token' do
      let(:perform_request) { post("#{routes.to(territory)}/create_token") }

      it 'includes the download pdf and xls' do
        perform_request

        token = Db::AccessToken.last&.token
        pdf = routes.territory_download_pdf_path(territory, access_token: token)
        xls = routes.territory_download_xls_path(territory, access_token: token)

        expect(response.body).to include(pdf)
        expect(response.body).to include(xls)
      end
    end
  end
end
