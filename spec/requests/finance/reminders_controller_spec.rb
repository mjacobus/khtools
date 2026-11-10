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

  def create(**attributes)
    post '/finance/reminders', params: { reminder: attributes }
  end

  it 'adds a monthly reminder with who is responsible' do
    member = current_account.finance_telegram_members.create!(telegram_id: 7, name: 'Bia')
    get '/finance/reminders/new'
    expect(page.css('#reminder_finance_telegram_member_id option').map(&:text))
      .to eq(['Sem responsável', 'Bia'])

    create(title: 'Pagamento internet', day: 10, finance_telegram_member_id: member.id)

    expect(response).to redirect_to('/finance/reminders')
    expect(Db::FinanceReminder.last).to have_attributes(day: 10, responsible: member)
  end

  it 'lists the reminders with their state this month' do
    internet

    get '/finance/reminders'

    expect(page.at('#recurring').text.squish)
      .to include('Pagamento internet', 'Todo dia 10', 'Pendente')
    expect(page.at('#recurring a[href$="/done"]').text).to eq('Feito')
  end

  it 'shows what is wrong with a reminder' do
    create(title: '', day: 40)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(page.css('.invalid-feedback, .error').size).to be >= 2
  end

  it 'changes a reminder' do
    reminder = internet
    get "/finance/reminders/#{reminder.id}/edit"
    expect(response).to have_http_status(:ok)

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
    expect(other.reload).to be_persisted

    create(title: 'X', day: 1, finance_telegram_member_id: stranger.id)
    expect(response).to have_http_status(:unprocessable_entity)
  end
end
