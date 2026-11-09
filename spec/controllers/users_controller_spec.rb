# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController do
  let(:current_user) { admin_user }
  let(:enabled) { true }
  let(:master) { true }
  let(:user) do
    User.create!(
      name: 'admin',
      master:,
      enabled:
    )
  end

  describe '#index' do
    context 'when user is master' do
      it 'responds with success' do
        get :index

        expect(response).to be_successful
      end

      it 'assigns all users' do
        get :index

        expect(assigns(:users)).to eq(User.order(:email))
      end
    end

    context 'when user is not master' do
      let(:current_user) { regular_user }

      it 'redirects to /' do
        get :index

        expect(response).to redirect_to('/')
      end
    end
  end
end
