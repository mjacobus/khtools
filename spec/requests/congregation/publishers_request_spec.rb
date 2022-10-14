# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Congregation::PublishersController, type: :request do
  # general
  let(:record) { factory.create(account_id: current_account.id) }
  let(:factory) { factories.publishers }
  let(:scope) { current_account.publishers.order(:name) }
  let(:key) { model_class.to_s.underscore.split('/').last.to_sym }
  let(:model_class) { Db::Publisher }

  # components
  let(:index_component) { Congregation::Publishers::IndexPageComponent }
  let(:show_component) { Congregation::Publishers::ShowPageComponent }
  let(:form_component) { Congregation::Publishers::FormPageComponent }

  # paths
  let(:index_path) { routes.publishers_path }
  let(:new_path) { routes.new_congregation_publisher_path }
  let(:edit_path) { routes.edit_congregation_publisher_path(record) }
  let(:show_path) { routes.to(record) }

  # attributes
  let(:valid_attributes) { factory.attributes.merge(name: 'new name') }
  let(:invalid_attributes) { factory.attributes.merge(name: '') }

  before do
    login_user(admin_user)
  end

  describe 'GET #index' do
    before { record }

    let(:perform_request) { get(index_path) }

    it 'responds with success' do
      perform_request

      expect(response).to be_successful
      expect(response.body).to include(record.name)
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = index_component.new(key.to_s.pluralize.to_sym => scope)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'GET #show' do
    let(:perform_request) { get(show_path) }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = show_component.new(key => record)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'GET #new' do
    let(:perform_request) { get(new_path) }
    let(:record) { model_class.new }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      record.account_id = current_account.id
      expected_component = form_component.new(key => record)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'POST #create' do
    let(:perform_request) { post(index_path, params: params) }

    context 'when payload is valid' do
      let(:params) { { key => valid_attributes } }

      it 'returns with success' do
        perform_request

        expect(response).to redirect_to(index_path)
      end

      it 'creates record' do
        expect { perform_request }.to change(model_class, :count).by(1)
      end
    end

    context 'when payload is invalid' do
      let(:params) { { key => invalid_attributes } }

      it 'responds with 422' do
        perform_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders form' do
        mock_renderer

        perform_request

        expected_component = form_component.new(key => model_class.new(invalid_attributes))
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  describe 'GET #edit' do
    let(:perform_request) { get(edit_path) }

    it 'returns with success' do
      perform_request

      expect(response).to be_successful
    end

    it 'renders the correct component' do
      mock_renderer

      perform_request

      expected_component = form_component.new(key => record)
      expect(renderer).to have_rendered_component(expected_component)
    end
  end

  describe 'PATCH #update' do
    let(:perform_request) { patch(show_path, params: params) }

    context 'when payload is valid' do
      let(:params) { { key => valid_attributes } }

      it 'redirects to index' do
        perform_request

        expect(response).to redirect_to(index_path)
      end

      it 'creates record' do
        expect { perform_request }.to change { record.reload.name }.to('new name')
      end
    end

    context 'when payload is invalid' do
      let(:params) { { key => invalid_attributes } }

      it 'returns with success' do
        perform_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders form' do
        mock_renderer

        perform_request

        record.attributes = invalid_attributes
        expected_component = form_component.new(key => record)
        expect(renderer).to have_rendered_component(expected_component)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:perform_request) { delete(show_path) }

    it 'redirects to index' do
      perform_request

      expect(response).to redirect_to(index_path)
    end

    it 'deletes record' do
      record

      expect { perform_request }.to change(model_class, :count).by(-1)
    end
  end
end
