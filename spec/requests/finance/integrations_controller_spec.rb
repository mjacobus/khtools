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
                            finance_drive_root_folder_id: 'FOLDER',
                            finance_telegram_chat_id: '-500', finance_confirmer_telegram_ids: '7')
  end

  def update(section, params)
    patch "/finance/integrations/#{section}", params: { integration: params }
  end

  it 'shows each section without revealing secrets' do
    %w[telegram drive ai].each do |section|
      get "/finance/integrations/#{section}"

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('BOT-SECRET')
      expect(response.body).not_to include('AI-SECRET')
      expect(response.body).not_to include('PDF-SECRET')
    end
  end

  it 'shows the Drive connection on the Drive section' do
    get '/finance/integrations/drive'

    expect(response.body).to include('Conectar Drive', 'FOLDER')
  end

  it 'does not know other sections' do
    get '/finance/integrations/other'

    expect(response).to have_http_status(:not_found)
  end

  it 'lists the people seen in the group, marking who can confirm' do
    current_account.finance_telegram_members.create!(telegram_id: 7, name: 'Bia Lima')
    current_account.finance_telegram_members.create!(telegram_id: 8, name: 'Caio Reis')

    get '/finance/integrations/telegram'

    page = Nokogiri::HTML(response.body)
    expect(page.at('input[type=checkbox][value="7"]')['checked']).to be_present
    expect(page.at('input[type=checkbox][value="8"]')['checked']).to be_nil
    expect(response.body).to include('-500', 'Bia Lima', 'Caio Reis')
  end

  it 'links each person in the group to a publisher, so the bot calls them by that name' do
    marcelo = factories.publishers.create(name: 'Marcelo Jacobus', account: current_account)
    member = current_account.finance_telegram_members.create!(telegram_id: 7, name: 'Marcelo J')

    get '/finance/integrations/telegram'
    select = Nokogiri::HTML(response.body).at('select[name="integration[member_publisher_ids][7]"]')
    expect(select.text).to include('Marcelo Jacobus')

    update(:telegram, member_publisher_ids: { '7' => marcelo.id.to_s })
    expect(member.reload.publisher).to eq(marcelo)

    update(:telegram, member_publisher_ids: { '7' => '' })
    expect(member.reload.publisher).to be_nil
  end

  it 'saves who can confirm from the checkboxes' do
    update(:telegram, confirmer_telegram_ids: ['', '8', '9'], telegram_chat_id: '-500')

    expect(current_account.reload.finance_confirmer_telegram_ids).to eq('8,9')
    expect(response).to redirect_to('/finance/integrations/telegram')
  end

  it 'leaves the other sections alone' do
    update(:ai, ai_api_key: 'NEW-AI')

    current_account.reload
    expect(current_account.ai_api_key).to eq('NEW-AI')
    expect(current_account).to have_attributes(finance_drive_root_folder_id: 'FOLDER',
                                               finance_telegram_chat_id: '-500',
                                               finance_confirmer_telegram_ids: '7')
  end

  it 'keeps secrets left blank' do
    update(:drive, drive_root_folder_id: 'FOLDER', statement_password: '')
    update(:telegram, telegram_chat_id: '-500', telegram_bot_token: '')

    current_account.reload
    expect(current_account.finance_telegram_bot_token).to eq('BOT-SECRET')
    expect(current_account.finance_statement_password).to eq('PDF-SECRET')
  end

  it 'cleans the chat id' do
    update(:telegram, telegram_chat_id: ' -5050. ')

    expect(current_account.reload.finance_telegram_chat_id).to eq('-5050')
  end

  it 'takes the folder id out of a Drive link' do
    update(:drive, drive_root_folder_id: 'https://drive.google.com/drive/folders/1AbC-d_9?usp=sharing')

    expect(current_account.reload.finance_drive_root_folder_id).to eq('1AbC-d_9')
  end

  it 'rejects a chat id that is not a number' do
    update(:telegram, telegram_chat_id: 'grupo')

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('O ID do grupo deve ser um número')
    expect(current_account.reload.finance_telegram_chat_id).to eq('-500')
  end

  it 'adds the group administrators to the people list' do
    allow(telegram).to receive(:chat_administrators).with(chat_id: '-500')
      .and_return([{ id: 9, name: 'Ana Souza' }])

    post '/finance/integrations/telegram/members'

    expect(current_account.finance_telegram_members.pluck(:telegram_id, :name))
      .to eq([[9, 'Ana Souza']])
    expect(response).to redirect_to('/finance/integrations/telegram')
  end

  it 'explains when Telegram refuses the administrators list' do
    allow(telegram).to receive(:chat_administrators).and_raise(Telegram::Client::Error,
                                                               'chat not found')

    post '/finance/integrations/telegram/members'
    follow_redirect!

    expect(response.body).to include('chat not found')
  end

  context 'without access' do
    let(:access) { false }

    it 'is denied' do
      get '/finance/integrations/telegram'

      expect(response).to redirect_to('/')
    end
  end
end
