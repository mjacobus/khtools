# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territories::RegularTerritoriesController, type: :request do
  describe 'GET #index' do
    it 'returns http success' do
      territory = factories.territories.create
      other = factories.commercial_territories.create

      login_user(admin_user)

      get '/territories/regular_territories'

      expect(response).to have_http_status(:success)
      expect(response.body).to match(territory.name)
      expect(response.body).not_to match(other.name)
    end
  end
end
