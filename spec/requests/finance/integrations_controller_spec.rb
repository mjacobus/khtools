# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::IntegrationsController do
  let(:access) { true }
  let(:telegram) { instance_double(Telegram::Client, chat_administrators: []) }

  before do
    allow(Telegram::Client).to receive(:new).and_return(telegram)
    grant_access(current_user) if access
    current_user.save!
    current_account.update!(finance_telegram_bot_token: 'BOT-SECRET', ai_api_key: 'AI-SECRET',
                            finance_statement_password: 'PDF-SECRET',
                            finance_telegram_chat_id: '-500', finance_confirmer_telegram_ids: '7')
  end

  def update(params)
    patch '/finance/integration', params: { integration: params }
  end

  it 'shows the settings without revealing secrets' do
    get '/finance/integration'

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('-500', 'Conectar Drive')
    expect(response.body).not_to include('BOT-SECRET')
    expect(response.body).not_to include('AI-SECRET')
    expect(response.body).not_to include('PDF-SECRET')
  end

  it 'lists the people seen in the group, marking who can confirm' do
    current_account.finance_telegram_members.create!(telegram_id: 7, name: 'Bia Lima')
    current_account.finance_telegram_members.create!(telegram_id: 8, name: 'Caio Reis')

    get '/finance/integration'

    page = Nokogiri::HTML(response.body)
    expect(page.at('input[type=checkbox][value="7"]')['checked']).to be_present
    expect(page.at('input[type=checkbox][value="8"]')['checked']).to be_nil
    expect(response.body).to include('Bia Lima', 'Caio Reis')
  end

  it 'saves who can confirm from the checkboxes' do
    update(confirmer_telegram_ids: ['', '8', '9'])

    expect(current_account.reload.finance_confirmer_telegram_ids).to eq('8,9')
  end

  it 'keeps secrets left blank and replaces the filled ones' do
    update(telegram_bot_token: '', ai_api_key: 'NEW-AI', statement_password: '')

    current_account.reload
    expect(current_account.finance_telegram_bot_token).to eq('BOT-SECRET')
    expect(current_account.ai_api_key).to eq('NEW-AI')
    expect(current_account.finance_statement_password).to eq('PDF-SECRET')
  end

  it 'cleans the chat id and takes the folder id out of a Drive link' do
    update(telegram_chat_id: ' -5050. ',
           drive_root_folder_id: 'https://drive.google.com/drive/folders/1AbC-d_9?usp=sharing')

    current_account.reload
    expect(current_account.finance_telegram_chat_id).to eq('-5050')
    expect(current_account.finance_drive_root_folder_id).to eq('1AbC-d_9')
  end

  it 'rejects a chat id that is not a number' do
    update(telegram_chat_id: 'grupo')

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('O ID do grupo deve ser um número')
    expect(current_account.reload.finance_telegram_chat_id).to eq('-500')
  end

  it 'adds the group administrators to the people list' do
    allow(telegram).to receive(:chat_administrators).with(chat_id: '-500')
      .and_return([{ id: 9, name: 'Ana Souza' }])

    post '/finance/integration/members'

    expect(current_account.finance_telegram_members.pluck(:telegram_id, :name))
      .to eq([[9, 'Ana Souza']])
    expect(response).to redirect_to('/finance/integration')
  end

  it 'explains when Telegram refuses the administrators list' do
    allow(telegram).to receive(:chat_administrators).and_raise(Telegram::Client::Error,
                                                               'chat not found')

    post '/finance/integration/members'
    follow_redirect!

    expect(response.body).to include('chat not found')
  end

  context 'without access' do
    let(:access) { false }

    it 'is denied' do
      get '/finance/integration'

      expect(response).to redirect_to('/')
    end
  end
end
