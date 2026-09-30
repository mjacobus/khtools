# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Congregation::PublishersController do
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
  let(:group) { factories.groups.create(account: current_account) }
  let(:valid_attributes) do
    factory.attributes(account_id: current_account.id, group_id: group.id).merge(name: 'new name')
  end
  let(:invalid_attributes) { factory.attributes.merge(name: '') }
  let(:contact_details) do
    {
      email: 'ana@example.com',
      phone: '51911112222',
      address: 'Rua A, 10',
      primary_emergency_contact_name: 'Maria',
      primary_emergency_contact_phone_number: '51999998888',
      secondary_emergency_contact_name: 'João',
      secondary_emergency_contact_phone_number: '51977776666'
    }
  end

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

    it 'shows the phone number' do
      record.update!(phone: '51911112222')

      perform_request

      expect(response.body).to include('(51) 91111-2222')
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

    it 'shows the privileges' do
      record.update!(elder: true, pioneer: true)

      perform_request

      expect(response.body).to include('Ancião, Pioneiro')
    end

    it 'shows the contact details' do
      record.update!(contact_details)

      perform_request

      expect(response.body).to include(
        'ana@example.com', '(51) 91111-2222', 'Rua A, 10',
        'Maria - (51) 99999-8888', 'João - (51) 97777-6666'
      )
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
    let(:perform_request) { post(index_path, params:) }

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

    context 'when the group belongs to another congregation' do
      let(:params) { { key => valid_attributes.merge(group_id: factories.groups.create.id) } }

      it 'does not create the record' do
        expect { perform_request }.not_to change(model_class, :count)
        expect(response).to have_http_status(:unprocessable_entity)
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

        record = model_class.new(invalid_attributes)
        record.account = current_account
        expected_component = form_component.new(key => record)
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
    let(:perform_request) { patch(show_path, params:) }

    context 'when payload is valid' do
      let(:params) { { key => valid_attributes } }

      it 'redirects to index' do
        perform_request

        expect(response).to redirect_to(index_path)
      end

      it 'creates record' do
        expect { perform_request }.to change { record.reload.name }.to('new name')
      end

      it 'updates the contact details' do
        params[key].merge!(contact_details)

        perform_request

        expect(record.reload.attributes.symbolize_keys).to include(contact_details)
      end

      it 'updates the privileges' do
        params[key].merge!(elder: '1', pioneer: '1')

        perform_request

        expect(record.reload.privileges).to eq(%i[elder pioneer])
      end
    end

    context 'when payload is invalid' do
      let(:params) { { key => invalid_attributes } }

      it 'returns with success' do
        perform_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 're-renders form' do
        skip 'TODO: Started failing comparison after rails upgrade to 7.1'
        mock_renderer

        perform_request

        record.attributes = invalid_attributes
        record.account = current_account

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
