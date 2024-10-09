require 'rails_helper'

RSpec.describe ConfigController do
  let(:parsed_body) { JSON.parse(response.body).symbolize_keys }

  describe 'GET #index' do
    let(:make_request) { get '/config', headers: { 'ACCEPT' => 'application/json' } }

    context 'when logged in and active' do
      it 'includes the google map key config' do
        ENV['GOOGLE_MAPS_STATIC_API_KEY'] = 'the-key'

        make_request

        expect(response).to have_http_status(:ok)
        expect(parsed_body).to eq(
          google_maps_static_api_key: 'the-key'
        )
      end
    end

    context 'when logged in but disabled' do
      before do
        current_user.update!(enabled: false)
      end

      it 'responds with forbidden' do
        make_request

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when not logged in' do
      let(:skip_login) { true }

      it 'responds with forbidden' do
        make_request

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
