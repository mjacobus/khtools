# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::DocumentsController do
  before do
    grant_access(current_user)
    current_user.save!
    travel_to Date.new(2026, 11, 12)
    current_account.finance_reminders.create!(title: 'Pagamento internet', day: 10)
  end

  it 'lists the pending monthly reminders to do, counted on the tab' do
    get '/finance/documents', params: { view: 'reminders' }
    page = Nokogiri::HTML(response.body)

    expect(page.at('#reminders-due').text.squish)
      .to include('Pagamento internet Todo mês, dia 10 Feito')
    expect(page.at('#document-tabs a[href*="reminders"] .badge').text).to eq('1')
  end
end
