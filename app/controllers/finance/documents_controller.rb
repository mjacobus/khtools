# frozen_string_literal: true

module Finance
  class DocumentsController < ApplicationController
    include BillPayments

    MONTH = /\A\d{4}-\d{2}\z/

    def index
      months = documents.where.not(competence: nil).distinct.pluck(:competence)
      @month = requested_month || months.max
      @months = (months | [@month]).compact.sort.reverse
      @groups = groups
      @paid_bills = paid_bills
    end

    def edit
      @document = editable.find(params[:id])
    end

    # Edits only reach the database once Drive took the new name and folder.
    def update
      @document = editable.find(params[:id])
      if assign_and_validate && refile
        redirect_to finance_documents_path(month: @document.competence),
                    notice: "Salvo como #{@document.drive_name}"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def documents
      current_account.finance_documents.where.not(state: 'discarded')
    end

    def editable
      documents.where.not(drive_file_id: nil)
    end

    # Any month can be opened, also one with nothing archived yet.
    def requested_month
      params[:month].to_s[MONTH]
    end

    def groups
      documents.where(competence: @month).order(:document_date, :id).group_by(&:kind)
        .sort_by { |kind, _| Db::FinanceDocument::KINDS.index(kind) }
    end

    helper_method def open_bills
      documents.open_bills.order(:due_date)
    end

    # The bills paid by this month's receipts, by id.
    def paid_bills
      documents.where(id: @groups.flat_map(&:last).filter_map(&:bill_id)).index_by(&:id)
    end

    def assign_and_validate
      fields = params.require(:document).permit(:kind, :competence, :document_date, :description,
                                                :amount)
      amount = fields.delete(:amount)
      @document.assign_attributes(fields.merge(amount_cents: Money.parse(text: amount)))
      valid = @document.valid?
      if amount.present? && @document.amount_cents.nil?
        @document.errors.add(:base, "Valor inválido: #{amount}")
        valid = false
      end
      valid
    end

    def refile
      @document.assign_attributes(drive_url: move_in_drive[:web_view_link], value_source: 'human',
                                  drive_filename: nil)
      @document.add_flag(:renamed)
      @document.record_correction(by_telegram_id: nil, by_name: current_user.name, text: 'khtools')
      @document.save!
    rescue GoogleDrive::Client::Error => exception
      flash.now[:alert] = "O Drive recusou a mudança: #{exception.message}"
      false
    end

    def move_in_drive
      folder = MonthFolder.new(account: current_account, drive:)
        .find_or_create(competence: @document.competence)
      drive.move(id: @document.drive_file_id, name: Naming.filename(document: @document),
                 parent_id: folder, app_properties:)
    end

    def app_properties
      @document.slice(:kind, :competence, :amount_cents).symbolize_keys
        .merge(khtools_id: @document.id)
    end

    def drive
      @drive ||= GoogleDrive::Client.new(
        refresh_token: current_account.finance_google_refresh_token,
        client_id: Rails.application.credentials.dig(:oauth, :google, :key),
        client_secret: Rails.application.credentials.dig(:oauth, :google, :secret)
      )
    end
  end
end
