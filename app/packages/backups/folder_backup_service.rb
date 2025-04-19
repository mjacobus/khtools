# frozen_string_literal: true

require 'digest'
require 'fileutils'

module Backups
  class FolderBackupService
    InvalidArgumentError = Class.new(ArgumentError)

    def initialize(app_name:, backup_dir: Rails.root.join('backups/folders'))
      @app_name = app_name
      @backup_dir = Pathname.new(backup_dir)
      @history_dir = @backup_dir.join('.bkp-history')
    end

    def backup(source_dir:, target_path: 'backup-{timestamp}.zip')
      source_dir = Pathname.new(source_dir)

      unless source_dir.directory?
        raise InvalidArgumentError,
              "Source directory does not exist: #{source_dir}"
      end

      timestamp = Time.zone.now.strftime('%Y%m%d%H%M')
      interpolated_name = target_path.gsub('{timestamp}', timestamp)
      tmp_path = @backup_dir.join(interpolated_name)

      FileUtils.mkdir_p(@backup_dir)
      FileUtils.mkdir_p(@history_dir)

      # Create zip
      system("zip -r -q #{tmp_path} #{source_dir}")

      # Check if zip contains real files
      output = `zipinfo -1 #{tmp_path}`
      files_in_zip = output.lines.reject { |line| line.strip.empty? || line.strip.end_with?('/') }

      if files_in_zip.empty?
        FileUtils.rm_f(tmp_path)
        return nil
      end

      # Compute hash of content
      hash = Digest::MD5.file(tmp_path).hexdigest
      history_marker = @history_dir.join("#{hash}.txt")

      if history_marker.exist?
        FileUtils.rm_f(tmp_path)
        return nil
      end

      # Write history and keep the backup
      FileUtils.touch(history_marker)

      final_name = "#{@app_name}_backup_#{timestamp}.zip".gsub('{hash}', hash)
      final_path = @backup_dir.join(final_name)

      FileUtils.mv(tmp_path, final_path)
      final_path.to_s
    end
  end
end
