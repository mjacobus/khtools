# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::ArchiveJob do
  # In-memory Drive: folders and files by parent id.
  let(:drive) do
    Class.new do
      attr_reader :folders, :files, :uploads, :updates, :tagged
      attr_accessor :fail_upload, :fail_update

      def initialize
        @folders = { ['ROOT', 'Arquivo Corrente'] => 'CURRENT' }
        @files = {}
        @tagged = {}
        @uploads = []
        @updates = []
      end

      def update_file(**args)
        if fail_update
          raise GoogleDrive::Client::Error, fail_update
        end

        updates << args.merge(bytes: File.binread(args[:path]))
        { id: args[:id], web_view_link: "https://drive/#{args[:id]}" }
      end

      def find_folder(name:, parent_id:) = folders[[parent_id, name]]
      def find_file(name:, parent_id:) = files[[parent_id, name]]
      def find_tagged_folder(tags:) = tagged.key(tags)
      def tag(id:, tags:) = tagged.store(id, tags)

      def create_folder(name:, parent_id:, tags: {})
        tag(id: "NEW-#{name}", tags:)
        folders[[parent_id, name]] = "NEW-#{name}"
      end

      def upload(**args)
        if fail_upload
          raise GoogleDrive::Client::Error, 'Drive HTTP 500'
        end

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

  describe 'who holds the cash, from the name printed on the S-24' do
    before do
      document.update!(sent_by_telegram_id: 7, sent_by_name: 'Bia Lima')
      Db::FinanceTelegramMember.remember(account: document.account, telegram_id: 8,
                                         name: 'Caio Souza')
      Db::FinanceTelegramMember.remember(account: document.account, telegram_id: 9,
                                         name: 'Caio Prado')
    end

    def holder_after_run(collector_name)
      document.update!(collector_name:)
      run
      document.slice(:cash_holder_telegram_id, :cash_holder_name).values
    end

    it 'is the group member with that name, accents and case aside' do
      expect(holder_after_run('CAIO SOUZÁ')).to eq([8, 'Caio Souza'])
    end

    it 'takes initials and short names' do
      expect(holder_after_run('Caio S.')).to eq([8, 'Caio Souza'])
    end

    it 'finds the member by the name of the user linked to them' do
      user = factories.users.create(name: 'Joana Prado', account: document.account)
      document.account.finance_telegram_members.create!(telegram_id: 10, name: 'Jô', user:)

      expect(holder_after_run('JOANA P.')).to eq([10, 'Joana Prado'])
    end

    it 'is just the name when nobody in the group matches it alone' do
      expect(holder_after_run('Caio')).to eq([nil, 'Caio'])
    end

    it 'is whoever sent it when no name was printed' do
      expect(holder_after_run(nil)).to eq([7, 'Bia Lima'])
    end
  end

  it 'asks the group who holds the cash of an archived S-24, starting with who sent it' do
    document.update!(sent_by_telegram_id: 7, sent_by_name: 'Bia Lima')

    run

    expect(document).to have_attributes(cash_holder_telegram_id: 7, cash_holder_name: 'Bia Lima',
                                        cash_message_id: telegram.sent.size + 500)
    expect(telegram.sent.last[:text]).to eq("💵 Dinheiro do S-24 de qua 04/11 (R$ 150,00)\n" \
                                            "Está com: Bia Lima\n" \
                                            'Pix: pendente')
  end

  it 'records in the description when the written S-24 total does not match' do
    document.update!(written_total_cents: 16_000)

    run

    expect(drive.uploads.last[:description])
      .to include('⚠️ Total escrito no recibo (R$ 160,00) não confere com a soma (R$ 150,00)')
  end

  it 'marks the document archived, deletes the local copy and tells the group' do
    run

    expect(document).to have_attributes(state: 'archived', drive_file_id: 'FILE',
                                        drive_url: 'https://drive/FILE')
    expect(File).not_to exist(document.local_path)
    expect(telegram.edits.last).to include(
      message_id: 300, html: true,
      text: 'Arquivado: <a href="https://drive/FILE">2026-11-04 - R$ 150,00 - S-24.jpg</a> ' \
            '→ Arquivo Corrente/2026-11/'
    )
  end

  context 'when a monthly file was already archived for the month' do
    let(:previous) do
      factories.finance_documents.create(account:, state: 'archived', kind: 's26',
                                         competence: '2026-11', mime_type: 'application/pdf',
                                         drive_file_id: 'OLD', drive_url: 'https://drive/OLD')
    end
    let(:document) do
      factories.finance_documents.create(account:, state: 'confirmed', kind: 's26',
                                         competence: '2026-11', mime_type: 'application/pdf',
                                         bot_message_id: 300)
    end

    before { previous }

    it 'uploads a new version of that file instead of a copy' do
      run

      expect(drive.uploads).to be_empty
      expect(drive.updates.last).to include(id: 'OLD', bytes: 'photo')
      expect(document).to have_attributes(state: 'archived', drive_file_id: 'OLD')
      expect(telegram.edits.last[:text]).to start_with('Substituído: <a href="https://drive/OLD">')
    end

    it 'uploads a new file when the old one is gone from Drive' do
      drive.fail_update = 'Drive HTTP 404: File not found'

      run

      expect(drive.uploads.last).to include(name: '2026-11 - S-26.pdf', parent_id: 'NOV')
      expect(document).to have_attributes(state: 'archived', drive_file_id: 'FILE')
    end
  end

  describe 'month folder' do
    let(:tags) { { khtools_root: 'ROOT', khtools_competence: '2026-11' } }

    it 'finds the month folder by its tags even after it was renamed or moved' do
      drive.tag(id: 'MOVED', tags:)

      run

      expect(drive.uploads.last[:parent_id]).to eq('MOVED')
    end

    it 'tags the month folder it finds by name' do
      run

      expect(drive.tagged).to eq('NOV' => tags)
    end

    it 'tags the month folder it creates' do
      drive.folders.delete(%w[CURRENT 2026-11])

      run

      expect(drive.tagged).to eq('NEW-2026-11' => tags)
    end
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

  it 'does not upload when another job claimed the document first' do
    allow(Db::FinanceDocument).to receive(:find).and_wrap_original do |original, id|
      original.call(id).tap do
        Db::FinanceDocument.where(id:).update_all(updated_at: 1.minute.from_now)
      end
    end

    run

    expect(drive.uploads).to be_empty
  end

  it 'ignores documents that are not confirmed' do
    document.update!(state: 'archived')

    run

    expect(drive.uploads).to be_empty
  end
end
