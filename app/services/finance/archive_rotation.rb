# frozen_string_literal: true

module Finance
  # Arquivo Corrente keeps the three months of the last audit and the months not audited yet;
  # older months go to Arquivo das contas (S-27b par. 50). Moves happen only when asked.
  class ArchiveRotation
    def initialize(account:, drive:)
      @account = account
      @drive = drive
    end

    def due_months
      current_months.keys.select { |month| cutoff && month < cutoff }.sort
    end

    def move(month:)
      unless due_months.include?(month)
        raise ArgumentError, "#{month} ainda fica no #{MonthFolder::CURRENT}"
      end

      @drive.move(id: current_months.fetch(month), name: month,
                  parent_id: archive(MonthFolder::PAST), app_properties: {})
    end

    private

    # First month of the last audited quarter (the audit report is filed in its last month).
    def cutoff
      last_audit = @account.finance_documents.where(kind: 'audit_report', state: 'archived')
        .maximum(:competence)
      last_audit && Competence.month(Date.parse("#{last_audit}-01") - 2.months)
    end

    def current_months
      @current_months ||= @drive.children(parent_id: archive(MonthFolder::CURRENT))
        .select { |child| child[:folder] && child[:name].match?(Backfill::MONTH) }
        .to_h { |child| [child[:name], child[:id]] }
    end

    def archive(name)
      @drive.find_folder(name:, parent_id: @account.finance_drive_root_folder_id) ||
        raise("Pasta \"#{name}\" não encontrada na raiz configurada")
    end
  end
end
