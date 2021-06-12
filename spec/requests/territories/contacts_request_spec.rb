# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Territories::ContactsController, type: :request do
  before do
    login_user(admin_user)
  end

  let(:territory) { factories.commercial_territories.create }
  let(:contact) do
    factories.contacts.create.tap do |rec|
      territory.contacts << rec
    end
  end

  describe 'GET #new' do
    it 'renders form' do
      get "/territories/commercial_territories/#{territory.id}/contacts/new"

      expect(response).to be_successful
      expect(response.body).to match('<form')
    end
  end

  describe 'GET #index' do
    it 'renders form' do
      contact

      get "/territories/commercial_territories/#{territory.id}/contacts"

      expect(response).to be_successful
      expect(response.body).to match(contact.name)
    end
  end

  describe 'POST #create' do
    context 'when params are valid' do
      it 'creates a contact' do
        params = factories.contacts.attributes

        expect do
          post("/territories/commercial_territories/#{territory.id}/contacts",
               params: { contact: params })
        end.to change(territory.reload.contacts, :count)

        expect(response).to redirect_to(
          "/territories/commercial_territories/#{territory.id}/contacts"
        )
      end
    end

    context 'when params are invalid' do
      it 'creates a contact' do
        params = factories.contacts.attributes.except(:name)

        expect do
          post(
            "/territories/commercial_territories/#{territory.id}/contacts",
            params: { contact: params }
          )
        end.not_to change(territory.reload.contacts, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match('<form')
      end
    end
  end
end
