# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicTalks::TalksController do
  let(:talk) { factories.public_talks.create }
  let(:index_page) do
    public_talks_talks_path(since: MeetingWeek.new.first_day.to_fs(:db))
  end

  before do
    login_user(admin_user)

    talk
  end

  describe 'GET #index' do
    let(:perform_request) { get('/public_talks/talks') }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      scope = Db::PublicTalk.order(:date).limit(100).offset(0)
      expected_component = PublicTalks::Talks::IndexPageComponent.new(scope)
      expect(renderer).to have_rendered_component(expected_component)
    end

    it 'takes since params' do
      mock_renderer

      get('/public_talks/talks', params: { since: '2021-02-01' })

      scope = Db::PublicTalk.order(:date).limit(100).offset(0).since('2021-02-01')
      expected_component = PublicTalks::Talks::IndexPageComponent.new(scope)

      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'GET #show' do
    let(:perform_request) { get("/public_talks/talks/#{talk.id}") }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = PublicTalks::Talks::ShowPageComponent.new(talk)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'GET #new' do
    let(:perform_request) { get('/public_talks/talks/new') }
    let(:talk) { Db::PublicTalk.new }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = PublicTalks::Talks::FormPageComponent.new(talk)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'POST #create' do
    let(:perform_request) { post('/public_talks/talks', params:) }

    context 'when payload is valid' do
      let(:params) { { talk: factories.public_talks.attributes } }

      it 'redirects to index' do
        perform_request

        expect(response).to redirect_to(index_page)
      end

      it 'creates record' do
        expect { perform_request }.to change(Db::PublicTalk, :count).by(1)
      end
    end

    context 'when payload is invalid' do
      let(:params) { { talk: { date: '' } } }

      it 'responds with 422' do
        perform_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders form' do
        mock_renderer

        perform_request

        expected_component = PublicTalks::Talks::FormPageComponent.new(
          Db::PublicTalk.new(date: '')
        )
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  describe 'GET #edit' do
    let(:perform_request) { get("/public_talks/talks/#{talk.id}/edit") }

    it 'responds with 200' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = PublicTalks::Talks::FormPageComponent.new(talk)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'PATCH #update' do
    let(:perform_request) do
      patch("/public_talks/talks/#{talk.id}", params:)
    end

    context 'when payload is valid' do
      let(:params) { { talk: factories.public_talks.attributes.merge(date: '2001-01-02') } }

      it 'responds with 422' do
        perform_request

        expect(response).to redirect_to(index_page)
      end

      it 'creates record' do
        expect { perform_request }.to change { talk.reload.date }.to(Time.zone.local(2001, 1, 2))
      end
    end

    context 'when payload is invalid' do
      let(:params) { { talk: { date: '' } } }

      it 'returns status 422' do
        perform_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders form' do
        skip 'TODO: Started failing comparison after rails upgrade to 7.1'
        mock_renderer

        perform_request

        talk.date = ''
        expected_component = PublicTalks::Talks::FormPageComponent.new(talk)
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:perform_request) { delete("/public_talks/talks/#{talk.id}") }

    it 'redirects to index' do
      perform_request

      expect(response).to redirect_to(index_page)
    end

    it 'deletes record' do
      expect { perform_request }.to change(Db::PublicTalk, :count).by(-1)
    end
  end
end
