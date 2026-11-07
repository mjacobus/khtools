# frozen_string_literal: true

module Finance
  # Brings in what people changed directly in Drive since the last run: a new name, a move to
  # another month folder, or the trash. Files are matched by id, so links never break.
  class DriveSync
    MONTH = /\A\d{4}-(0[1-9]|1[0-2])\z/

    def initialize(account:, drive:)
      @account = account
      @drive = drive
    end

    def sync
      token = @account.finance_drive_changes_token
      if token.blank?
        @account.update!(finance_drive_changes_token: @drive.start_page_token)
      else
        changes, next_token = @drive.changes(page_token: token)
        apply(changes)
        @account.update!(finance_drive_changes_token: next_token)
      end
    end

    private

    def apply(changes)
      documents = @account.finance_documents.where(drive_file_id: changes.pluck(:id))
        .index_by(&:drive_file_id)
      changes.each do |change|
        document = documents[change[:id]]
        if document
          update(document, change)
        end
      end
    end

    def update(document, change)
      if change[:removed] || change[:trashed]
        document.add_flag(:trashed)
      else
        document.drive_filename = change[:name]
        document.competence = month(change[:parents]) || document.competence
      end
      document.save!
    end

    def month(parents)
      Array(parents).lazy.map { |id| folder_name(id) }.find { |name| name.match?(MONTH) }
    end

    def folder_name(id)
      @folder_names ||= {}
      @folder_names[id] ||= @drive.name(id:)
    end
  end
end
