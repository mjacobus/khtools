# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'
require 'digest'

# rubocop:disable RSpec/ExampleLength
RSpec.describe Backups::FolderBackupService, type: :service do
  let(:tmp_source_dir) { Rails.root.join('tmp/test_backup_src') }
  let(:backup_dir)     { Rails.root.join('tmp/test_backups') }
  let(:history_dir)    { backup_dir.join('.bkp-history') }
  let(:app_name)       { 'dummyapp' }

  before do
    FileUtils.mkdir_p(tmp_source_dir)
    FileUtils.mkdir_p(backup_dir)
    File.write(tmp_source_dir.join('file.txt'), 'initial content')
  end

  after do
    FileUtils.rm_rf(tmp_source_dir)
    FileUtils.rm_rf(backup_dir)
  end

  def silence_output
    original_stdout = $stdout
    original_stderr = $stderr
    $stdout = File.open(File::NULL, 'w')
    $stderr = File.open(File::NULL, 'w')
    yield
  ensure
    $stdout = original_stdout
    $stderr = original_stderr
  end

  it 'creates a zip file with timestamp and hash when content is new' do
    allow(Time).to receive_message_chain(:zone, :now, :strftime).and_return('the-timestamp')
    allow(Digest::MD5).to receive_message_chain(:file, :hexdigest).and_return('the-hash')

    service = described_class.new(app_name:, backup_dir:)

    result = nil
    silence_output do
      result = service.backup(source_dir: tmp_source_dir,
                              target_path: 'backup_{timestamp}_{hash}.zip')
    end

    expect(result).to be_a(String)
    expect(File.exist?(result)).to be true
    expect(File.basename(result)).to eq('backup_the-timestamp_the-hash.zip')

    expect(File.exist?(history_dir.join('the-hash.txt'))).to be true
  end

  it 'returns nil and does not duplicate zip if content has not changed' do
    service = described_class.new(app_name:, backup_dir:)

    first = nil
    second = nil

    silence_output do
      first = service.backup(source_dir: tmp_source_dir, target_path: 'backup-{timestamp}.zip')
      second = service.backup(source_dir: tmp_source_dir, target_path: 'backup-{timestamp}.zip')
    end

    expect(first).to be_a(String)
    expect(File.exist?(first)).to be true
    expect(second).to be_nil

    # Deve haver exatamente um .zip e um .txt no histórico
    zips = Dir.glob(backup_dir.join('*.zip'))
    markers = Dir.glob(history_dir.join('*.txt'))

    expect(zips.size).to eq(1)
    expect(markers.size).to eq(1)
  end

  it 'returns nil and does not create zip if source folder is empty' do
    FileUtils.rm_rf(tmp_source_dir)
    FileUtils.mkdir_p(tmp_source_dir)

    service = described_class.new(app_name:, backup_dir:)

    result = nil
    silence_output do
      result = service.backup(source_dir: tmp_source_dir, target_path: 'backup-{timestamp}.zip')
    end

    expect(result).to be_nil

    zips = Dir.glob(backup_dir.join('*.zip'))
    history = Dir.glob(backup_dir.join('.bkp-history', '*.txt'))

    expect(zips).to be_empty
    expect(history).to be_empty
  end

  it "raises error if source folder doesn't exist" do
    invalid_path = Rails.root.join('tmp/does_not_exist')
    service = described_class.new(app_name:, backup_dir:)

    expect do
      silence_output do
        service.backup(source_dir: invalid_path)
      end
    end.to raise_error(Backups::FolderBackupService::InvalidArgumentError)
  end
end
# rubocop:enable RSpec/ExampleLength
