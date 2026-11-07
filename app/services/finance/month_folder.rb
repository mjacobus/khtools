# frozen_string_literal: true

module Finance
  # The Drive folder of a month: Arquivo Corrente/<month> or, for months already audited,
  # Arquivo das contas/<month>. Tagged once found, so it is still found after someone renames
  # or moves it.
  class MonthFolder
    CURRENT = 'Arquivo Corrente'
    PAST = 'Arquivo das contas'

    def initialize(account:, drive:)
      @account = account
      @drive = drive
    end

    def find_or_create(competence:)
      tags = { khtools_root: root, khtools_competence: competence }
      @drive.find_tagged_folder(tags:) || named(competence, tags)
    end

    private

    def root
      @account.finance_drive_root_folder_id
    end

    def named(competence, tags)
      current = archive(CURRENT)
      folder = [current, archive(PAST, required: false)].compact.lazy
        .filter_map { |parent| @drive.find_folder(name: competence, parent_id: parent) }.first
      if folder
        @drive.tag(id: folder, tags:)
        folder
      else
        @drive.create_folder(name: competence, parent_id: current, tags:)
      end
    end

    def archive(name, required: true)
      folder = @drive.find_folder(name:, parent_id: root)
      if folder.nil? && required
        raise "Pasta \"#{name}\" não encontrada na raiz configurada"
      end

      folder
    end
  end
end
