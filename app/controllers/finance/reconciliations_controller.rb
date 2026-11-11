# frozen_string_literal: true

module Finance
  # Checks a month's documents against the bank statement PDFs (nothing from them is kept: only
  # the opening balance is).
  class ReconciliationsController < ApplicationController
    MONTH = /\A\d{4}-\d{2}\z/

    def show
      @month = month
      @opening_cents = balance.opening_cents
    end

    def create
      @month = month
      save_opening
      @opening_cents = balance.opening_cents
      @reconciliation = reconciliation
      render :show
    rescue Pdf::Error => exception
      flash.now[:alert] = "Não consegui ler o extrato: #{exception.message}"
      render :show, status: :unprocessable_entity
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

    def reconciliation
      texts = Array(params[:statements]).compact_blank.map { |file| text(file.path) }
      if texts.any?
        Reconciliation.new(account: current_account, month: @month,
                           holder: Statement.holder(texts.first),
                           lines: texts.flat_map { |text| Statement.parse(text) }.uniq(&:doc),
                           opening_cents: @opening_cents)
      end
    end

    def text(path)
      Pdf.text(path:)
    rescue Pdf::PasswordError
      Pdf.text(path:, password: current_account.finance_statement_password)
    end
  end
end
