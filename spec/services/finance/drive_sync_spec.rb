# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::DriveSync do
  let(:drive) { instance_double(GoogleDrive::Client, start_page_token: 'START') }
  let(:account) do
    factories.accounts.create.tap { |account| account.update!(finance_drive_changes_token: 'T1') }
  end
  let!(:document) do
    factories.finance_documents.create(account:, state: 'archived', kind: 's26',
                                       competence: '2026-09', drive_file_id: 'F1',
                                       mime_type: 'application/pdf')
  end

  def sync(*changes)
    allow(drive).to receive(:changes).with(page_token: 'T1').and_return([changes, 'T2'])
    described_class.new(account:, drive:).sync
    document.reload
  end

  def change(**attributes)
    { id: 'F1', removed: false, name: '2026-09 - S-26.pdf', parents: ['SEP'], trashed: false }
      .merge(attributes)
  end

  before { allow(drive).to receive(:name).with(id: 'SEP').and_return('2026-09') }

  it 'starts from now on the first run' do
    account.update!(finance_drive_changes_token: nil)

    described_class.new(account:, drive:).sync

    expect(account.reload.finance_drive_changes_token).to eq('START')
  end

  it 'takes the name given in Drive and remembers where it stopped' do
    expect(sync(change(name: 'S-26 setembro.pdf')).drive_name).to eq('S-26 setembro.pdf')
    expect(account.reload.finance_drive_changes_token).to eq('T2')
  end

  it 'takes the month of the folder the file was moved to' do
    allow(drive).to receive(:name).with(id: 'OCT').and_return('2026-10')

    expect(sync(change(parents: ['OCT'])).competence).to eq('2026-10')
  end

  it 'keeps the month when the file went to a folder that is not a month' do
    allow(drive).to receive(:name).with(id: 'X').and_return('Organizar')

    expect(sync(change(parents: ['X'])).competence).to eq('2026-09')
  end

  it 'flags files deleted or trashed in Drive' do
    expect(sync(change(trashed: true))).to be_flagged(:trashed)
  end

  it 'ignores files it does not know' do
    sync(change(id: 'OTHER'))

    expect(drive).not_to have_received(:name)
  end
end
