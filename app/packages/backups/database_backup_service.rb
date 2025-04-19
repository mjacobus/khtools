require 'digest'
require 'fileutils'

module Backups
  class DatabaseBackupService
    def initialize(app_name:, backup_dir: Rails.root.join('backups/sqlite'))
      @app_name = app_name
      @backup_dir = Pathname.new(backup_dir)
      @checksum_file = Rails.root.join('tmp/.last_sqlite_checksum')
    end

    def backup(db_dir:, db_file: 'production.sqlite3') # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      db_dir = Pathname.new(db_dir)
      db_file  = db_dir.join(db_file)
      wal_file = Pathname("#{db_file}-wal")
      shm_file = Pathname("#{db_file}-shm")

      files = [db_file, wal_file, shm_file]
      return nil unless files.all?(&:exist?)

      hash_input = files.map { |f| File.read(f) }.join
      current_hash = Digest::MD5.hexdigest(hash_input)
      previous_hash = File.exist?(@checksum_file) ? File.read(@checksum_file).strip : nil

      return nil if current_hash == previous_hash

      timestamp = Time.now.strftime('%Y%m%d%H%M')
      zip_name = "#{@app_name}_sqlite_backup_#{timestamp}.zip"
      zip_path = @backup_dir.join(zip_name)

      tmp_dir = Rails.root.join('tmp/sqlite_tmp_backup')
      FileUtils.rm_rf(tmp_dir)
      FileUtils.mkdir_p(tmp_dir)
      files.each { |f| FileUtils.cp(f, tmp_dir) }

      system("zip -j #{zip_path} #{tmp_dir}/*")
      FileUtils.rm_rf(tmp_dir)
      File.write(@checksum_file, current_hash)

      zip_path.to_s
    end
  end
end
