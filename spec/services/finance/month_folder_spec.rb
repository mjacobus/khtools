# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::MonthFolder do
  let(:account) do
    factories.accounts.create.tap do |account|
      account.update!(finance_drive_root_folder_id: 'ROOT')
    end
  end
  let(:drive) { instance_double(GoogleDrive::Client, find_tagged_folder: nil, tag: nil) }
  let(:tags) { { khtools_root: 'ROOT', khtools_competence: '2024-08' } }
  let(:folder) { described_class.new(account:, drive:) }

  before do
    allow(drive).to receive(:find_folder) { |name:, parent_id:| folders[[parent_id, name]] }
  end

  def folders
    { ['ROOT', 'Arquivo Corrente'] => 'CURRENT', ['ROOT', 'Arquivo das contas'] => 'PAST',
      %w[PAST 2024-08] => 'AUG' }
  end

  it 'finds an old month in Arquivo das contas and tags it' do
    expect(folder.find_or_create(competence: '2024-08')).to eq('AUG')
    expect(drive).to have_received(:tag).with(id: 'AUG', tags:)
  end

  it 'prefers the tagged folder' do
    allow(drive).to receive(:find_tagged_folder).with(tags:).and_return('TAGGED')

    expect(folder.find_or_create(competence: '2024-08')).to eq('TAGGED')
  end

  it 'creates a missing month in Arquivo Corrente' do
    allow(drive).to receive(:create_folder).and_return('NEW')

    expect(folder.find_or_create(competence: '2026-12')).to eq('NEW')
    expect(drive).to have_received(:create_folder)
      .with(name: '2026-12', parent_id: 'CURRENT',
            tags: hash_including(khtools_competence: '2026-12'))
  end
end
