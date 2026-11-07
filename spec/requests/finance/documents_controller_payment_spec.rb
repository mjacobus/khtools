# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::DocumentsController do
  let(:bill) do
    document(kind: 'bill', description: 'Luz', document_date: Date.new(2026, 9, 20),
             amount_cents: 7412)
  end
  let(:receipt) do
    document(kind: 'payment_receipt', document_date: Date.new(2026, 10, 3), amount_cents: 7412)
  end

  let(:drive) { instance_double(GoogleDrive::Client) }

  before do
    grant_access(current_user)
    current_user.save!
    travel_to Date.new(2026, 10, 10)
    allow(GoogleDrive::Client).to receive(:new).and_return(drive)
    allow(Finance::MonthFolder).to receive(:new)
      .and_return(instance_double(Finance::MonthFolder, find_or_create: 'OCT'))
    allow(drive).to receive(:move).and_return(id: 'F', web_view_link: 'https://drive/moved')
  end

  def document(**attributes)
    factories.finance_documents.create(account: current_account, state: 'archived',
                                       competence: '2026-09', drive_url: 'https://drive/x',
                                       drive_file_id: SecureRandom.hex(4),
                                       **attributes)
  end

  def page
    Nokogiri::HTML(response.body)
  end

  def pay(**fields)
    patch "/finance/documents/#{bill.id}/payment",
          params: { payment: { due_date: '2026-10-05', paid_on: '',
                               receipt_id: receipt.id }.merge(fields) }
  end

  it 'offers the unlinked receipts, the ones with the same amount first' do
    document(kind: 'payment_receipt', original_filename: 'outro.pdf', amount_cents: 100,
             document_date: Date.new(2026, 10, 1))
    receipt

    get "/finance/documents/#{bill.id}/payment"

    options = page.css('select[name="payment[receipt_id]"] option').pluck('value')
    expect(options).to eq(['', receipt.id.to_s, options.last])
  end

  it 'links the receipt and takes its date as the payment date' do
    pay

    expect(bill.reload).to have_attributes(due_date: Date.new(2026, 10, 5),
                                           paid_on: Date.new(2026, 10, 3), payments: [receipt])
    expect(response).to redirect_to('/finance/documents?month=2026-10')
  end

  it 'files the bill in the month it was paid, moving it in Drive (S-27b par. 20)' do
    pay

    expect(bill.reload).to have_attributes(competence: '2026-10', drive_url: 'https://drive/moved')
    expect(drive).to have_received(:move)
      .with(hash_including(id: bill.drive_file_id, name: bill.drive_name, parent_id: 'OCT'))
  end

  it 'leaves a bill paid in its own month where it is' do
    pay(paid_on: '2026-09-28', receipt_id: '')

    expect(bill.reload.competence).to eq('2026-09')
    expect(drive).not_to have_received(:move)
  end

  it 'saves nothing when Drive refuses the move' do
    allow(drive).to receive(:move).and_raise(GoogleDrive::Client::Error, 'Drive HTTP 500')

    pay

    expect(bill.reload).to have_attributes(paid_on: nil, competence: '2026-09')
    expect(response.body).to include('Drive HTTP 500')
  end

  it 'marks a bill paid without a receipt' do
    pay(paid_on: '2026-10-08', receipt_id: '')

    expect(bill.reload).to have_attributes(paid_on: Date.new(2026, 10, 8), payments: [])
  end

  it 'unlinks the receipt and reopens the bill' do
    pay
    pay(receipt_id: '', paid_on: '')

    expect(bill.reload).to have_attributes(paid_on: nil, payments: [])
  end

  it 'only handles bills' do
    get "/finance/documents/#{receipt.id}/payment"

    expect(response).to have_http_status(:not_found)
  end

  it 'shows on the month page what is paid, late or open' do
    bill.update!(due_date: Date.new(2026, 10, 5))

    get '/finance/documents', params: { month: '2026-09' }

    expect(page.at('li .badge').text).to eq('vencida em 05/10')
    expect(page.at('#open-bills').text).to include('Luz')
    expect(page.at('#open-bills summary').text.squish).to eq('1 fatura em aberto · 1 vencida')
  end
end
