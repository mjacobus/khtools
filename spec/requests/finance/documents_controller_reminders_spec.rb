# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::DocumentsController do
  before do
    grant_access(current_user)
    current_user.save!
    travel_to Date.new(2026, 11, 12)
  end

  def reminders
    get '/finance/documents', params: { view: 'reminders' }
    Nokogiri::HTML(response.body).css('#recurring li').map { |li| li.text.squish }
  end

  def internet
    current_account.finance_reminders.create!(title: 'Pagamento internet', day: 10)
  end

  it 'adds a monthly reminder' do
    post '/finance/documents/reminders',
         params: { reminder: { title: 'Pagamento internet', day: 10 } }

    expect(response).to redirect_to('/finance/documents?view=reminders')
    expect(reminders).to include(a_string_starting_with('Pagamento internet todo dia 10'))
  end

  it 'explains a reminder that could not be added' do
    post '/finance/documents/reminders', params: { reminder: { title: '', day: 10 } }

    follow_redirect!
    expect(response.body).to include('Informe o lembrete e um dia de 1 a 31.')
  end

  it 'marks a pending reminder done for the month, and counts it on the tab until then' do
    reminder = internet
    expect(reminders.first).to include('pendente')
    expect(Nokogiri::HTML(response.body).at('#reminders-due').text.squish)
      .to include('Pagamento internet Todo mês, dia 10 Feito')
    badge = Nokogiri::HTML(response.body).at('#document-tabs a[href*="reminders"] .badge')
    expect(badge.text).to eq('1')

    post "/finance/documents/reminders/#{reminder.id}/done"

    expect(reminders.first).to include('✓ feito em 2026-11')
    expect(reminder.reload.done_month).to eq('2026-11')
  end

  it 'removes a reminder' do
    reminder = internet

    delete "/finance/documents/reminders/#{reminder.id}"

    expect(reminders).to be_empty
  end

  it 'does not touch the reminders of another congregation' do
    other = factories.accounts.create.finance_reminders.create!(title: 'Outro', day: 1)

    delete "/finance/documents/reminders/#{other.id}"

    expect(response).to have_http_status(:not_found)
    expect(other.reload).to be_persisted
  end
end
