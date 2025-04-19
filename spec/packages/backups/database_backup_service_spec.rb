require 'rails_helper'
require 'fileutils'

RSpec.describe Backups::DatabaseBackupService do
  let(:tmp_db_dir) { Rails.root.join('tmp/test_sqlite') }
  let(:backup_dir) { Rails.root.join('tmp/test_backups') }
  let(:app_name)   { 'testapp' }

  let(:main_file) { tmp_db_dir.join('production.sqlite3') }
  let(:wal_file)  { tmp_db_dir.join('production.sqlite3-wal') }
  let(:shm_file)  { tmp_db_dir.join('production.sqlite3-shm') }

  before do
    FileUtils.mkdir_p(tmp_db_dir)
    FileUtils.mkdir_p(backup_dir)

    File.write(main_file, 'sqlite data')
    File.write(wal_file, 'wal data')
    File.write(shm_file, 'shm data')
  end

  after do
    FileUtils.rm_rf(tmp_db_dir)
    FileUtils.rm_rf(backup_dir)
    FileUtils.rm_f(Rails.root.join('tmp/.last_sqlite_checksum'))
  end

  it 'creates a zip file and returns its path when data has changed' do
    service = described_class.new(app_name:, backup_dir: backup_dir)
    result = service.backup(db_dir: tmp_db_dir)

    expect(result).to be_a(String)
    expect(File.exist?(result)).to be true
    expect(File.basename(result)).to match(/^#{app_name}_sqlite_backup_\d{12}\.zip$/)
  end

  it 'returns nil when no changes are detected' do
    service = described_class.new(app_name:, backup_dir: backup_dir)
    first = service.backup(db_dir: tmp_db_dir)
    second = service.backup(db_dir: tmp_db_dir)

    expect(first).to be_a(String)
    expect(second).to be_nil
  end
end
