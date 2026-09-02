# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reports::TerritoryAssignmentsController do
  let(:current_user) { admin_user }
  let(:publisher) { factories.publishers.create(account: current_account, name: 'João') }
  let(:territory) { factories.territories.create(account: current_account, name: '7') }

  before do
    factories.territory_assignments.create(
      territory:, assignee: publisher, assigned_at: '2025-10-05', returned_at: '2025-11-20'
    )
  end

  describe 'GET #index' do
    it 'renders the report for the given service year' do
      get '/reports/territory_assignments', params: { service_year: '2025' }

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Registro de Designação de Território')
      expect(response.body).to include('João')
      expect(response.body).to include('05/10/2025')
      expect(response.body).to include('20/11/2025')
    end

    it 'defaults to the current service year' do
      travel_to(Date.new(2026, 2, 1)) do
        get '/reports/territory_assignments'
      end

      expect(response.body).to include('João')
    end

    it 'leaves the territory out when the service year has no overlap' do
      get '/reports/territory_assignments', params: { service_year: '2023' }

      expect(response).to have_http_status(:success)
      expect(response.body).not_to include('João')
    end

    it 'defaults to regular territories' do
      commercial = factories.commercial_territories.create(account: current_account, name: 'C-9')

      get '/reports/territory_assignments'

      expect(response.body).to include(territory.name)
      expect(response.body).not_to include(commercial.name)
    end

    it 'filters by territory type' do
      commercial = factories.commercial_territories.create(account: current_account, name: 'C-9')

      get '/reports/territory_assignments', params: { type: 'commercial' }

      expect(response.body).to include(commercial.name)
    end

    it 'includes every type when asked for all of them' do
      commercial = factories.commercial_territories.create(account: current_account, name: 'C-9')

      get '/reports/territory_assignments', params: { type: 'all' }

      expect(response.body).to include(commercial.name)
      expect(response.body).to include(territory.name)
    end

    it 'ignores territories from other accounts' do
      other = factories.territories.create(name: 'Territory-of-someone-else')

      get '/reports/territory_assignments'

      expect(response.body).not_to include(other.name)
    end

    it 'redirects users without permission' do
      login_user(regular_user)

      get '/reports/territory_assignments'

      expect(response).to redirect_to('/')
    end
  end

  describe 'GET #index as xlsx' do
    it 'sends a spreadsheet named after the service year' do
      get '/reports/territory_assignments.xlsx', params: { service_year: '2025' }

      expect(response).to have_http_status(:success)
      expect(response.headers['Content-Disposition'])
        .to match(/filename="registro-de-designacao-de-territorio-2025-2026.xlsx"/)
      expect(response.body).to start_with('PK')
    end
  end

  describe 'GET #index as pdf' do
    it 'sends a pdf named after the service year' do
      get '/reports/territory_assignments.pdf', params: { service_year: '2025' }

      expect(response).to have_http_status(:success)
      expect(response.headers['Content-Type']).to eq('application/pdf')
      expect(response.headers['Content-Disposition'])
        .to match(/registro-de-designacao-de-territorio-2025-2026\.pdf/)
    end
  end
end
