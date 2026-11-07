# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::DocumentsController do
  before do
    grant_access(current_user)
    current_user.save!
    travel_to Date.new(2026, 9, 6)
    factories.finance_documents.create(account: current_account, state: 'archived', kind: 's24',
                                       competence: '2026-09', document_date: Date.new(2026, 9, 2))
  end

  def checklist
    get '/finance/documents', params: { month: '2026-09' }
    Nokogiri::HTML(response.body).css('#checklist li').map { |li| li.text.squish }
  end

  it 'shows what the month has and what is missing' do
    expect(checklist).to include(a_string_starting_with('✓ S-24 qua 02/09'),
                                 a_string_starting_with('✗ S-24 sáb 05/09'),
                                 a_string_starting_with('✗ S-26'))
  end

  it 'sums it up in a panel that opens on click' do
    get '/finance/documents', params: { month: '2026-09' }
    html = Nokogiri::HTML(response.body)

    expect(html.at('details#checklist-panel summary').text.squish).to eq('Checklist 1/7')
    expect(html.at('[data-turbo="true"] details#checklist-panel #checklist')).to be_present
  end

  it 'marks a meeting without collection, and undoes it' do
    post '/finance/documents/meeting_exceptions', params: { date: '2026-09-05' }

    expect(response).to redirect_to('/finance/documents?month=2026-09')
    expect(checklist).to include(a_string_starting_with('— 05/09 sem reunião'))

    delete '/finance/documents/meeting_exceptions', params: { date: '2026-09-05' }

    expect(checklist).to include(a_string_starting_with('✗ S-24 sáb 05/09'))
  end

  it 'expects the S-24 of a moved meeting on its new day' do
    post '/finance/documents/meeting_exceptions',
         params: { date: '2026-09-05', moved_to: '04/09/2026' }

    expect(checklist).to include(a_string_starting_with('✗ S-24 sex 04/09'),
                                 a_string_starting_with('— 05/09 mudou para 04/09'))
  end
end
