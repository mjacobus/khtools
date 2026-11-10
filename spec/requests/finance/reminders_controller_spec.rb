# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::RemindersController do
  before do
    grant_access(current_user)
    current_user.save!
    travel_to Date.new(2026, 11, 12)
  end

  def page
    Nokogiri::HTML(response.body)
  end

  def internet
    current_account.finance_reminders.create!(title: 'Pagamento internet', day: 10)
  end

  it 'adds a monthly reminder with who is responsible' do
    member = current_account.finance_telegram_members.create!(telegram_id: 7, name: 'Bia')

    post '/finance/reminders', params: { reminder: { title: 'Pagamento internet', day: 10,
                                                     finance_telegram_member_id: member.id } }

    expect(response).to redirect_to('/finance/reminders')
    expect(current_account.finance_reminders.last).to have_attributes(day: 10, responsible: member)
  end

  it 'lists the reminders to edit, with their state this month' do
    internet

    get '/finance/reminders'

    expect(page.at('#recurring input[name="reminder[title]"]')['value']).to eq('Pagamento internet')
    expect(page.at('#recurring').text).to include('pendente')
  end

  it 'explains a reminder that could not be saved' do
    post '/finance/reminders', params: { reminder: { title: '', day: 10 } }

    follow_redirect!
    expect(response.body).to include('Informe o lembrete e um dia de 1 a 31.')
  end

  it 'changes a reminder' do
    reminder = internet

    patch "/finance/reminders/#{reminder.id}", params: { reminder: { title: 'Internet', day: 12 } }

    expect(reminder.reload).to have_attributes(title: 'Internet', day: 12)
  end

  it 'marks it done for the month, back to where it was marked' do
    reminder = internet

    post "/finance/reminders/#{reminder.id}/done",
         headers: { 'HTTP_REFERER' => 'http://www.example.com/finance/documents?view=reminders' }

    expect(response).to redirect_to('/finance/documents?view=reminders')
    expect(reminder.reload.done_month).to eq('2026-11')
  end

  it 'removes a reminder' do
    reminder = internet

    delete "/finance/reminders/#{reminder.id}"

    expect(current_account.finance_reminders.exists?(reminder.id)).to be(false)
  end

  it 'does not touch the reminders or people of another congregation' do
    other_account = factories.accounts.create
    other = other_account.finance_reminders.create!(title: 'Outro', day: 1)
    stranger = other_account.finance_telegram_members.create!(telegram_id: 9, name: 'Zé')

    delete "/finance/reminders/#{other.id}"
    expect(response).to have_http_status(:not_found)

    post '/finance/reminders', params: { reminder: { title: 'X', day: 1,
                                                     finance_telegram_member_id: stranger.id } }
    expect(response).to have_http_status(:not_found)
    expect(other.reload).to be_persisted
  end
end
