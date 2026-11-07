# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::ArchiveRotation do
  let(:account) do
    factories.accounts.create.tap do |account|
      account.update!(finance_drive_root_folder_id: 'ROOT')
    end
  end
  let(:drive) { instance_double(GoogleDrive::Client, move: nil) }
  let(:rotation) { described_class.new(account:, drive:) }

  before do
    archives = { 'Arquivo Corrente' => 'CURRENT', 'Arquivo das contas' => 'PAST' }
    allow(drive).to receive(:find_folder) do |name:, parent_id:|
      parent_id == 'ROOT' && archives[name]
    end
    folders = %w[2026-04 2026-05 2026-06 2026-08 Rascunhos]
    allow(drive).to receive(:children).with(parent_id: 'CURRENT')
      .and_return(folders.map { |name| { id: "F#{name}", name:, folder: true } })
  end

  def audit(competence)
    factories.finance_documents.create(account:, state: 'archived', kind: 'audit_report',
                                       competence:)
  end

  it 'keeps the last audited quarter and later months, and offers to move the older ones' do
    audit('2026-08')

    expect(rotation.due_months).to eq(%w[2026-04 2026-05])
  end

  it 'offers nothing before any audit' do
    expect(rotation.due_months).to eq([])
  end

  it 'moves a month folder to Arquivo das contas, keeping its name' do
    audit('2026-08')

    rotation.move(month: '2026-05')

    expect(drive).to have_received(:move).with(id: 'F2026-05', name: '2026-05', parent_id: 'PAST',
                                               app_properties: {})
  end

  it 'refuses a month that is not due' do
    audit('2026-08')

    expect { rotation.move(month: '2026-06') }.to raise_error(ArgumentError)
  end
end
