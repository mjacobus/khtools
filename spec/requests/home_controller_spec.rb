# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController do
  let(:perform_request) { get '/' }

  context 'when the user is linked to a publisher' do
    let(:publisher) { factories.publishers.create(account: current_account, user: current_user) }

    it 'lists the territories assigned to the publisher' do
      mine = factories.territories.create(account: current_account, assignee: publisher)
      other = factories.territories.create(account: current_account)

      perform_request

      expect(response.body).to include('Meus Territórios', mine.name)
      expect(response.body).not_to include(other.name)
    end

    it 'ignores territories of other congregations assigned to the publisher' do
      foreign = factories.territories.create(assignee: publisher)

      perform_request

      expect(response.body).not_to include(foreign.name)
    end

    it 'says so when no territory is assigned' do
      publisher

      perform_request

      expect(response.body).to include('Meus Territórios', 'Nenhum território designado para você.')
    end
  end

  context 'when the user is not linked to a publisher' do
    it 'does not show the section' do
      perform_request

      expect(response.body).not_to include('Meus Territórios')
    end
  end
end
