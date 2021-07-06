# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicController, type: :request do
  let(:talk) { factories.public_talks.create }

  before do
    talk
  end

  describe 'GET #public_talks' do
    let(:perform_request) { get('/discursos') }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      scope = Db::PublicTalk.within_week
      expected_component = Public::PublicTalksComponent.new(scope)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end
end
