# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reports::TerritoryAssignmentSpreadsheet do
  subject(:spreadsheet) { described_class.new(report) }

  let(:report) do
    Reports::TerritoryAssignmentReport.new(
      account:, service_year: ServiceYear.new(2025), type: Db::RegularTerritory
    )
  end
  let(:account) { factories.accounts.create }
  let(:territory) { factories.territories.create(account:, name: '7') }
  let(:sheet) { spreadsheet.to_package.workbook.worksheets.first }

  before do
    factories.territory_assignments.create(
      territory:,
      assignee: factories.publishers.create(account:, name: 'João'),
      assigned_at: '2025-10-05',
      returned_at: '2025-11-20'
    )
  end

  def values
    sheet.rows.map { |row| row.cells.map(&:value) }
  end

  it 'names the sheet after the service year' do
    expect(sheet.name).to eq('2025-2026')
  end

  it 'puts the form title and the service year on top' do
    expect(values[0].first).to eq('Registro de Designação de Território')
    expect(values[1].first).to eq('Ano de Serviço: 2025/2026')
  end

  it 'renders the two header rows of the form' do
    expect(values[2].first(3)).to eq(['Terr. n.º', 'Última data concluída*', 'Designado para'])
    expect(values[3][2]).to eq('Data da designação')
    expect(values[3][3]).to eq('Data da conclusão')
  end

  it 'renders the territory number and the assignee on the first row' do
    expect(values[4][0]).to eq('7')
    expect(values[4][2]).to eq('João')
  end

  it 'renders the assignment dates on the second row' do
    expect(values[5][2]).to eq('05/10/2025')
    expect(values[5][3]).to eq('20/11/2025')
  end

  it 'has two columns per assignment block plus the two fixed ones' do
    expect(values[3].size).to eq(2 + (4 * 2))
  end

  it 'merges the assignee name over its two date columns' do
    expect(sheet.to_xml_string).to include("<mergeCell ref='C5:D5'")
  end

  it 'merges the territory number over both rows' do
    expect(sheet.to_xml_string).to include("<mergeCell ref='A5:A6'")
  end

  it 'builds a readable stream' do
    expect(spreadsheet.to_stream.read).to start_with('PK')
  end

  describe '#filename' do
    it 'includes the service year' do
      expect(spreadsheet.filename)
        .to eq('registro-de-designacao-de-territorio-2025-2026.xlsx')
    end
  end
end
