# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::DocumentsController do
  let(:rotation) { instance_double(Finance::ArchiveRotation, due_months: %w[2026-04 2026-05]) }

  before do
    grant_access(current_user)
    current_user.save!
    allow(GoogleDrive::Client).to receive(:new)
    allow(Finance::ArchiveRotation).to receive(:new).and_return(rotation)
  end

  it 'lists the audited months that can leave Arquivo Corrente' do
    get '/finance/documents/archive'

    expect(Nokogiri::HTML(response.body).css('#due-months li').map { |li| li.text.squish })
      .to eq(['2026-04 Mover para Arquivo das contas', '2026-05 Mover para Arquivo das contas'])
  end

  it 'moves a month when asked' do
    allow(rotation).to receive(:move)

    post '/finance/documents/archive', params: { month: '2026-04' }

    expect(rotation).to have_received(:move).with(month: '2026-04')
    expect(response).to redirect_to('/finance/documents/archive')
  end

  it 'shows why Drive refused' do
    allow(rotation).to receive(:move).and_raise(GoogleDrive::Client::Error, 'Drive HTTP 500')

    post '/finance/documents/archive', params: { month: '2026-04' }
    follow_redirect!

    expect(response.body).to include('Drive HTTP 500')
  end
end
