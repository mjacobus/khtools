# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicTalks::SpeakersController do
  let(:speaker) { factories.public_speakers.create }

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

      expected_component = PublicTalks::Speakers::IndexPageComponent.new(Db::PublicSpeaker.all)
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
    let(:speaker) { Db::PublicSpeaker.new }

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
      let(:params) { { speaker: factories.public_speakers.attributes } }

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
          Db::PublicSpeaker.new(name: '')
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
      let(:params) { { speaker: factories.public_speakers.attributes.merge(name: 'new name') } }

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
