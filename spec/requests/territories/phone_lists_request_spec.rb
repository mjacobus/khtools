# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Territories::PhoneLists', type: :request do
  let(:described_class) { Territories::PhoneListsController }

  describe 'GET /xls' do
    it 'returns http success' do
      territory = factories.phone_list_territories.create
      login_user(admin_user)
      get "/territories/phone_lists/#{territory.id}/xls"

      expect(response).to have_http_status(:success)
      expect(response.headers['Content-Type']).to eq('application/octet-stream')
      expect(response.headers['Content-Disposition']).to match(/^attachment/)
      expect(response.headers['Content-Disposition']).to match(/filename="#{territory.name}.xls"/)
    end
  end
end
