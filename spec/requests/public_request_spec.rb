# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicController do
  let(:account) { factories.accounts.create }
  let(:local_congregation) { factories.congregations.create(account:, local: true) }
  let(:talk) { factories.public_talks.create(account:, congregation: local_congregation) }
  let(:skip_login) { true }

  describe 'GET #public_talks' do
    let(:perform_request) { get("/discursos/#{account.id}") }

    before do
      talk
    end

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      scope = account.public_talks.upcoming.local.since(MeetingWeek.new.first_day)
      expected_component = Public::PublicTalksComponent.new(scope)
      expect(renderer).to have_rendered_component(expected_component)
    end

    it 'does not show local talks of other congregations' do
      other_account = factories.accounts.create
      other_local = factories.congregations.create(account: other_account, local: true)
      speaker = factories.public_speakers.create(
        account: other_account, name: 'Orador de outra congregação'
      )
      factories.public_talks.create(account: other_account, congregation: other_local, speaker:)

      perform_request

      expect(response.body).not_to include('Orador de outra congregação')
    end

    it 'responds with 404 for an unknown congregation' do
      get('/discursos/0')

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /discursos' do
    it 'redirects to the first congregation' do
      first = factories.accounts.create
      factories.accounts.create

      get('/discursos')

      expect(response).to redirect_to("/discursos/#{first.id}")
    end
  end
end
