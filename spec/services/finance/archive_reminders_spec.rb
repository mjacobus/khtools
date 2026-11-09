# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::ArchiveReminders do
  let(:factories) { TestFactories.new }
  let(:account) { factories.accounts.create }

  def document(kind, competence)
    factories.finance_documents.create(account:, state: 'archived', kind:, competence:)
  end

  def due(today)
    described_class.new(account:, today:).due.map(&:title)
  end

  it 'asks for the audit of a period that ended without its report' do
    document('s24', '2026-06')
    document('audit_report', '2026-08')

    expect(due(Date.new(2026, 12, 10))).to eq(['Fazer a auditoria de setembro a novembro de 2026'])
  end

  it 'waits for the period to end' do
    document('audit_report', '2026-08')

    expect(due(Date.new(2026, 11, 9))).to be_empty
  end

  it 'ignores periods before the first document' do
    document('s24', '2026-10')

    expect(due(Date.new(2026, 12, 10))).to eq(['Fazer a auditoria de setembro a novembro de 2026'])
  end

  it 'asks in January to remove what is older than seven years' do
    document('s24', '2019-12')
    document('s24', '2020-01')
    document('audit_report', '2026-11')

    expect(due(Date.new(2027, 1, 5))).to eq(
      ['Verificar o arquivo e eliminar os registros de 2019 e antes (1 documento no sistema)']
    )
  end

  it 'names the period of the last audit in the rules' do
    document('audit_report', '2026-02')

    rule = described_class.new(account:, today: Date.new(2026, 3, 10)).rules.first
    expect(rule.title)
      .to eq('Destruir os S-24 em papel do secretário de dezembro de 2025 a fevereiro de 2026')
  end
end
