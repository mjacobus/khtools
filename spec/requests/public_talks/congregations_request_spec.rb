# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicTalks::CongregationsController, type: :request do
  let(:congregation) { factories.congregations.create }

  before do
    login_user(admin_user)

    congregation
  end

  describe 'GET /index' do
    let(:perform_request) { get('/public_talks/congregations') }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = Congregations::IndexPageComponent.new(Db::Congregation.all)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end
end
