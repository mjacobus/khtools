# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::ReconciliationsController do
  let(:statement) { Rails.root.join('spec/fixtures/finance/statement.txt').read }
  let(:upload) do
    Rack::Test::UploadedFile.new(StringIO.new('%PDF'), 'application/pdf',
                                 original_filename: 'extrato.pdf')
  end

  before do
    grant_access(current_user)
    current_user.save!
    allow(Finance::Pdf).to receive(:text).and_return(statement)
  end

  def document(kind, date, cents)
    factories.finance_documents.create(account: current_account, state: 'archived', kind:,
                                       document_date: date, amount_cents: cents,
                                       competence: date.strftime('%Y-%m'),
                                       drive_url: "https://drive/#{kind}")
  end

  def page = Nokogiri::HTML(response.body)

  it 'asks for the statement and the opening balance' do
    get '/finance/reconciliation', params: { month: '2026-10' }

    expect(page.at('input[type=file][name="statements[]"]')).to be_present
    expect(page.at('input[name=opening]')).to be_present
  end

  it 'keeps the opening balance for the month' do
    post '/finance/reconciliation', params: { month: '2026-10', opening: '1.200,00' }

    expect(current_account.finance_balances.pluck(:competence, :opening_cents))
      .to eq([['2026-10', 120_000]])
    get '/finance/reconciliation', params: { month: '2026-10' }
    expect(page.at('input[name=opening]')['value']).to eq('1.200,00')
  end

  it 'lists the statement lines with the document that explains each one' do
    document('s24', Date.new(2026, 10, 1), 15_000)

    post '/finance/reconciliation',
         params: { month: '2026-10', opening: '1.200,00', statements: [upload] }

    rows = page.css('#statement-lines tbody tr').map { |row| row.css('td').map { _1.text.squish } }
    expect(rows.first).to eq(['02/10', 'R$ 150,00', 'ANA TESOUREIRA', 'Depósito do S-24 de 01/10'])
    expect(page.at('#statement-lines a[href="https://drive/s24"]')).to be_present
    expect(page.at('#balances').text.squish).to include('Diferença')
  end

  it "opens a locked statement with the account's statement password" do
    current_account.update!(finance_statement_password: '123')
    pdf = class_double(Finance::Pdf).as_stubbed_const(transfer_nested_constants: true)
    allow(pdf).to receive(:text).with(path: anything).and_raise(Finance::Pdf::PasswordError)
    allow(pdf).to receive(:text).with(path: anything, password: '123').and_return(statement)

    post '/finance/reconciliation', params: { month: '2026-10', statements: [upload] }

    expect(page.css('#statement-lines tbody tr').size).to eq(4)
  end
end
