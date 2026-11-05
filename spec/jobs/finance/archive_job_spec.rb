# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::ArchiveJob do
  # In-memory Drive: folders and files by parent id.
  let(:drive) do
    Class.new do
      attr_reader :folders, :files, :uploads
      attr_accessor :fail_upload

      def initialize
        @folders = { ['ROOT', 'Arquivo Corrente'] => 'CURRENT' }
        @files = {}
        @uploads = []
      end

      def find_folder(name:, parent_id:) = folders[[parent_id, name]]
      def find_file(name:, parent_id:) = files[[parent_id, name]]

      def create_folder(name:, parent_id:)
        folders[[parent_id, name]] = "NEW-#{name}"
      end

      def upload(**args)
        raise GoogleDrive::Client::Error, 'Drive HTTP 500' if fail_upload

        uploads << args.merge(bytes: File.binread(args[:path]))
        files[[args[:parent_id], args[:name]]] = 'FILE'
        { id: 'FILE', web_view_link: 'https://drive/FILE' }
      end
    end.new
  end
  let(:telegram) { FakeTelegram.new }
  let(:account) do
    factories.accounts.create.tap do |account|
      account.update!(finance_telegram_bot_token: 'token', finance_google_refresh_token: 'refresh',
                      finance_drive_root_folder_id: 'ROOT')
    end
  end
  let(:document) do
    factories.finance_documents.create(
      account:, state: 'confirmed', kind: 's24', document_date: Date.new(2026, 11, 4),
      competence: '2026-11', amount_cents: 15_000, congregation_cents: 12_000,
      worldwide_cents: 3000, mime_type: 'image/jpeg',
      confirmed_by: 'Ana', confirmed_at: Time.zone.local(2026, 11, 5, 10), bot_message_id: 300
    )
  end

  before do
    allow(GoogleDrive::Client).to receive(:new).and_return(drive)
    allow(Telegram::Client).to receive(:new).with(token: 'token').and_return(telegram)
    drive.folders[%w[CURRENT 2026-11]] = 'NOV'
    FileUtils.mkdir_p(File.dirname(document.local_path))
    File.binwrite(document.local_path, 'photo')
  end

  after { FileUtils.rm_rf(Rails.root.join('storage/finance')) }

  def run
    described_class.perform_now(document.id)
    document.reload
  end

  it 'uploads to the month folder with readable and machine metadata' do
    run

    upload = drive.uploads.last
    expect(upload).to include(name: '2026-11-04 - R$ 150,00 - S-24.jpg', parent_id: 'NOV',
                              bytes: 'photo', mime_type: 'image/jpeg')
    expect(upload[:description]).to eq('Congregação R$ 120,00 · Obra mundial R$ 30,00 · ' \
                                       'competência 2026-11 · confirmado por Ana em 05/11/2026')
    expect(upload[:app_properties]).to include(kind: 's24', competence: '2026-11',
                                               amount_cents: 15_000, khtools_id: document.id)
  end

  it 'marks the document archived, deletes the local copy and tells the group' do
    run

    expect(document).to have_attributes(state: 'archived', drive_file_id: 'FILE',
                                        drive_url: 'https://drive/FILE')
    expect(File).not_to exist(document.local_path)
    expect(telegram.edits.last).to include(
      message_id: 300,
      text: 'Arquivado: 2026-11-04 - R$ 150,00 - S-24.jpg → Arquivo Corrente/2026-11/'
    )
  end

  it 'creates the month folder when missing' do
    drive.folders.delete(%w[CURRENT 2026-11])

    run

    expect(drive.uploads.last[:parent_id]).to eq('NEW-2026-11')
  end

  it 'never overwrites a file with the same name' do
    drive.files[['NOV', '2026-11-04 - R$ 150,00 - S-24.jpg']] = 'OLD'
    drive.files[['NOV', '2026-11-04 - R$ 150,00 - S-24 (2).jpg']] = 'OLD2'

    run

    expect(drive.uploads.last[:name]).to eq('2026-11-04 - R$ 150,00 - S-24 (3).jpg')
  end

  it 'downloads the original again when the local copy is gone' do
    FileUtils.rm_f(document.local_path)
    telegram.files[document.telegram_file_id] = 'from-telegram'

    run

    expect(drive.uploads.last[:bytes]).to eq('from-telegram')
  end

  it 'keeps the document confirmed when Drive fails' do
    drive.fail_upload = true

    run

    expect(document).to have_attributes(state: 'confirmed', last_error: include('Drive HTTP 500'))
    expect(File).to exist(document.local_path)
    expect(telegram.edits.last[:text]).to eq(Finance::Messages::ARCHIVE_FAILED)
  end

  it 'refuses to create the Arquivo Corrente folder' do
    drive.folders.clear

    run

    expect(document).to have_attributes(state: 'confirmed', last_error: include('Arquivo Corrente'))
    expect(drive.folders).to be_empty
  end

  def encrypt_local_copy(password)
    plain = "#{document.local_path}.plain"
    File.binwrite(plain, finance_pdf('Extrato'))
    system('qpdf', '--encrypt', password, password, '256', '--', plain, document.local_path.to_s,
           exception: true)
  end

  it 'uploads decryptable statements without the password' do
    skip('needs qpdf') unless system('which', 'qpdf', out: File::NULL)
    account.update!(finance_statement_password: 'senha')
    document.update!(kind: 'statement', mime_type: 'application/pdf', flags: 'decryptable')
    encrypt_local_copy('senha')

    run

    expect(drive.uploads.last[:bytes]).to start_with('%PDF')
    expect(drive.uploads.last[:bytes]).not_to include('/Encrypt')
    expect(File).not_to exist("#{document.local_path}.decrypted.pdf")
  end

  it 'ignores documents that are not confirmed' do
    document.update!(state: 'archived')

    run

    expect(drive.uploads).to be_empty
  end
end
