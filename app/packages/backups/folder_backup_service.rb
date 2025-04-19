require 'digest'
require 'fileutils'

module Backups
  class FolderBackupService
    InvalidArgumentError = Class.new(ArgumentError)

    def initialize(app_name:, backup_dir: Rails.root.join('backups/folders'))
      @app_name = app_name
      @backup_dir = Pathname.new(backup_dir)
    end

    def backup(source_dir:, target_path: 'backup-{timestamp}.zip')
      source_dir = Pathname.new(source_dir)

      if !source_dir.directory?
        raise InvalidArgumentError, "Source directory does not exist: #{source_dir}"
      end

      timestamp = Time.now.strftime('%Y%m%d%H%M')
      interpolated_name = target_path.gsub('{timestamp}', timestamp)
      tmp_path = @backup_dir.join(interpolated_name)

      FileUtils.mkdir_p(@backup_dir)

      # Create zip
      system("zip -r -q #{tmp_path} #{source_dir}")

      output = `zipinfo -1 #{tmp_path}`
      # Remove directory entries (ending with "/") and empty lines
      files_in_zip = output.lines.reject { |line| line.strip.empty? || line.strip.end_with?('/') }

      if files_in_zip.empty?
        FileUtils.rm_f(tmp_path)
        return nil
      end

      # Compute hash
      hash = Digest::MD5.file(tmp_path).hexdigest
      final_name = "#{@app_name}_backup_#{hash}.zip"
      final_path = @backup_dir.join(final_name)

      if File.exist?(final_path)
        FileUtils.rm_f(tmp_path)
        return nil
      end

      FileUtils.mv(tmp_path, final_path)
      final_path.to_s
    end
  end
end
