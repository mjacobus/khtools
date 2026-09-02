# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reports::TerritoryAssignmentsTableComponent, type: :component do
  subject(:component) { described_class.new(report:) }

  let(:report) do
    Reports::TerritoryAssignmentReport.new(
      account:, service_year: ServiceYear.new(2025), type: Db::RegularTerritory
    )
  end
  let(:account) { factories.accounts.create }
  let(:publisher) { factories.publishers.create(account:, name: 'João') }
  let(:territory) { factories.territories.create(account:, name: '7') }
  let(:rendered) { render_inline(component) }

  before do
    factories.territory_assignments.create(
      territory:, assignee: publisher, assigned_at: '2025-10-05', returned_at: '2025-11-20'
    )
  end

  it 'repeats the "Designado para" header once per column' do
    expect(rendered.css('thead th[colspan="2"]').map(&:text)).to eq(['Designado para'] * 4)
  end

  it 'spans the fixed headers over both header rows' do
    headers = rendered.css('thead th[rowspan="2"]').map(&:text)

    expect(headers).to eq(['Terr. n.º', 'Última data concluída*'])
  end

  it 'renders the date sub headers once per column' do
    headers = rendered.css('thead tr:last-child th').map(&:text)

    expect(headers).to eq(['Data da designação', 'Data da conclusão'] * 4)
  end

  it 'gives each territory two rows' do
    expect(rendered.css('tbody tr').size).to eq(2)
  end

  it 'groups the two rows of a territory so printing never splits them' do
    factories.territories.create(account:, name: '8')

    expect(rendered.css('tbody').size).to eq(2)
    expect(rendered.css('tbody').map { |body| body.css('tr').size }).to eq([2, 2])
  end

  it 'puts the territory number and the assignee on the first row' do
    first = rendered.css('tbody tr').first

    expect(first.css('td[rowspan="2"]').first.text).to eq('7')
    expect(first.css('td[colspan="2"]').first.text).to eq('João')
  end

  it 'puts the assignment dates on the second row' do
    dates = rendered.css('tbody tr').last.css('td').map(&:text)

    expect(dates.first(2)).to eq(['05/10/2025', '20/11/2025'])
  end

  it 'leaves unused blocks empty' do
    dates = rendered.css('tbody tr').last.css('td').map(&:text)

    expect(dates.size).to eq(8)
    expect(dates.last(6)).to all(be_blank)
  end

  it 'renders the last completed date' do
    factories.territory_assignments.create(
      territory:, assignee: publisher, assigned_at: '2024-01-01', returned_at: '2024-03-15'
    )

    expect(rendered.css('tbody td[rowspan="2"]').map(&:text)).to eq(['7', '15/03/2024'])
  end

  it 'does not link territories by default' do
    expect(rendered.css('tbody a')).to be_empty
  end

  context 'when linked' do
    subject(:component) { described_class.new(report:, linked: true) }

    it 'links the territory to its page' do
      link = rendered.css('tbody a').first

      expect(link.text).to eq('7')
      expect(link[:href]).to eq("/territories/regular_territories/#{territory.id}")
    end
  end
end
