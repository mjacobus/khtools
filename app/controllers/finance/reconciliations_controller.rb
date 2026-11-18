# frozen_string_literal: true

module Finance
  # Checks a month's documents against the statements filed for it (kind "statement"), read
  # from Drive or, before archiving, the local copy. Only the opening balance is stored.
  class ReconciliationsController < ApplicationController
    include DocumentFiles

    MONTH = /\A\d{4}-\d{2}\z/

    def show
      @month = month
      @opening_cents = balance.opening_cents
      @statements = statements.to_a
      @unreadable = {}
      @reconciliation = reconciliation
    end

    def create
      @month = month
      save_opening
      redirect_to finance_reconciliation_path(month: @month)
    end

    private

    def month
      params[:month].to_s[MONTH] || Competence.month(Date.current.prev_month)
    end

    def balance
      @balance ||= current_account.finance_balances.find_or_initialize_by(competence: @month)
    end

    def save_opening
      cents = Money.parse(text: params[:opening])
      if cents
        balance.update!(opening_cents: cents)
      end
    end

    def statements
      current_account.finance_documents.where(kind: 'statement', competence: @month)
        .where.not(state: %w[discarded failed]).order(:id)
    end

    def reconciliation
      texts = @statements.filter_map { |document| readable_text(document) }
      if texts.any?
        Reconciliation.new(account: current_account, month: @month,
                           holder: Statement.holder(texts.first),
                           lines: texts.flat_map { |text| Statement.parse(text) }.uniq(&:doc),
                           opening_cents: @opening_cents)
      end
    end

    # A statement that can't be opened is named on the page; the others are still checked.
    def readable_text(document)
      text(document)
    rescue Pdf::Error, GoogleDrive::Client::Error => exception
      @unreadable[document.id] = exception.message
      nil
    end

    def text(document)
      Tempfile.create(['statement', '.pdf'], binmode: true) do |file|
        file.write(bytes(document))
        file.flush
        pdf_text(file.path)
      end
    end

    def bytes(document)
      if document.drive_file_id
        drive.download(id: document.drive_file_id)
      else
        File.binread(local_file(document))
      end
    end

    def pdf_text(path)
      Pdf.text(path:)
    rescue Pdf::PasswordError
      Pdf.text(path:, password: current_account.finance_statement_password)
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
