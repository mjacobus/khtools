# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicTalks::SpeakersController do
  let(:speaker) { factories.public_speakers.create(account: current_account) }
  let(:foreign_speaker) { factories.public_speakers.create }
  let(:attributes) { factories.public_speakers.attributes(account: current_account) }

  before do
    login_user(admin_user)

    speaker
  end

  describe 'GET #index' do
    let(:perform_request) { get('/public_talks/speakers') }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      speakers = current_account.public_speakers.order(:name)
      expected_component = PublicTalks::Speakers::IndexPageComponent.new(speakers)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'GET #show' do
    let(:perform_request) { get("/public_talks/speakers/#{speaker.id}") }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = PublicTalks::Speakers::ShowPageComponent.new(speaker)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'GET #new' do
    let(:perform_request) { get('/public_talks/speakers/new') }
    let(:speaker) { current_account.public_speakers.new }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = PublicTalks::Speakers::FormPageComponent.new(speaker)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'POST #create' do
    let(:perform_request) { post('/public_talks/speakers', params:) }

    context 'when payload is valid' do
      let(:params) { { speaker: attributes } }

      it 'returns with success' do
        perform_request

        expect(response).to redirect_to('/public_talks/speakers')
      end

      it 'creates record' do
        expect { perform_request }.to change(Db::PublicSpeaker, :count).by(1)
      end
    end

    context 'when payload is invalid' do
      let(:params) { { speaker: { name: '' } } }

      it 'responds with 422' do
        perform_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders form' do
        mock_renderer

        perform_request

        expected_component = PublicTalks::Speakers::FormPageComponent.new(
          current_account.public_speakers.new(name: '')
        )
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  describe 'GET #edit' do
    let(:perform_request) { get("/public_talks/speakers/#{speaker.id}/edit") }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = PublicTalks::Speakers::FormPageComponent.new(speaker)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'PATCH #update' do
    let(:perform_request) do
      patch("/public_talks/speakers/#{speaker.id}", params:)
    end

    context 'when payload is valid' do
      let(:params) do
        { speaker: attributes.merge(name: 'new name') }
      end

      it 'redirects to index' do
        perform_request

        expect(response).to redirect_to('/public_talks/speakers')
      end

      it 'creates record' do
        expect { perform_request }.to change { speaker.reload.name }.to('new name')
      end
    end

    context 'when payload is invalid' do
      let(:params) { { speaker: { name: '' } } }

      it 'returns with success' do
        perform_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders form' do
        skip 'TODO: Started failing comparison after rails upgrade to 7.1'
        mock_renderer

        perform_request

        speaker.name = ''
        expected_component = PublicTalks::Speakers::FormPageComponent.new(speaker)
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  context 'when the speaker belongs to another congregation' do
    it 'is not listed' do
      foreign_speaker

      get('/public_talks/speakers')

      expect(response.body).not_to include(foreign_speaker.name)
    end

    it 'is not shown' do
      get("/public_talks/speakers/#{foreign_speaker.id}")

      expect(response).to have_http_status(:not_found)
    end

    it 'is not deleted' do
      foreign_speaker

      expect { delete("/public_talks/speakers/#{foreign_speaker.id}") }
        .not_to change(Db::PublicSpeaker, :count)
    end
  end

  describe 'DELETE #destroy' do
    let(:perform_request) { delete("/public_talks/speakers/#{speaker.id}") }

    it 'redirects to index' do
      perform_request

      expect(response).to redirect_to('/public_talks/speakers')
    end

    it 'deletes record' do
      expect { perform_request }.to change(Db::PublicSpeaker, :count).by(-1)
    end
  end
end
