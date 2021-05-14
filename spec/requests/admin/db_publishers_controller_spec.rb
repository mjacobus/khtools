# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DbPublishersController, type: :request do
  describe '#index' do
    context 'when logged out' do
      let(:current_user) { nil }

      it 'redirects to login page' do
        get admin_db_publishers_url

        expect(response).to redirect_to('/')
      end
    end

    context 'when user is not an admin' do
      let(:current_user) { regular_user }

      it 'redirects to login page' do
        get admin_db_publishers_url

        expect(response).to redirect_to('/')
      end
    end

    context 'when user is an admin' do
      let(:current_user) { admin_user }

      it 'loads the page' do
        get admin_db_publishers_url

        expect(response).to be_successful
      end
    end
  end
end
