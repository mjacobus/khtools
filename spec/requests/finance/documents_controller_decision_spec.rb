# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::DocumentsController do
  include ActiveJob::TestHelper

  let(:telegram) { FakeTelegram.new }
  let(:waiting) do
    factories.finance_documents.create(account: current_account, state: 'suggested',
                                       kind: 'statement', competence: '2026-09',
                                       telegram_chat_id: -100, bot_message_id: 300)
  end

  before do
    grant_access(current_user)
    current_user.save!
    allow(Telegram::Client).to receive(:new).and_return(telegram)
  end

  def actions
    get '/finance/documents', params: { month: '2026-09' }
    Nokogiri::HTML(response.body).css('#documents form[action*="/confirm"], ' \
                                      '#documents form[action*="/discard"]')
      .pluck('action')
  end

  it 'offers to confirm or discard a document waiting for confirmation' do
    id = waiting.id

    expect(actions).to eq(["/finance/documents/#{id}/confirm", "/finance/documents/#{id}/discard"])
  end

  it 'confirms it: archives it like the Telegram button, by whoever is logged in' do
    post "/finance/documents/#{waiting.id}/confirm"

    expect(response).to redirect_to('/finance/documents?month=2026-09')
    expect(waiting.reload).to have_attributes(state: 'confirmed', confirmed_by: current_user.name)
    expect(enqueued_jobs.pluck('job_class')).to include('Finance::ArchiveJob')
    expect(telegram.edits.last).to include(message_id: 300, text: 'Arquivando…')
  end

  it 'asks for the month before confirming' do
    waiting.update!(competence: nil)

    post "/finance/documents/#{waiting.id}/confirm"

    expect(waiting.reload.state).to eq('suggested')
    expect(flash[:error]).to eq('Falta o mês: corrija o documento antes de confirmar.')
  end

  it 'discards it' do
    post "/finance/documents/#{waiting.id}/discard"

    expect(waiting.reload.state).to eq('discarded')
    expect(telegram.edits.last).to include(message_id: 300, text: 'Ignorado (não é das contas).')
  end

  it 'says when someone already handled it' do
    waiting.update!(state: 'archived')

    post "/finance/documents/#{waiting.id}/discard"

    expect(waiting.reload.state).to eq('archived')
    expect(flash[:error]).to eq('Este documento já foi tratado.')
  end
end
