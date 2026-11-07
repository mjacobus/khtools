# frozen_string_literal: true

module Finance
  # Due date, payment date and payment receipt of a bill (actions of DocumentsController, so
  # the same access covers them).
  module BillPayments
    extend ActiveSupport::Concern

    included { helper_method :same_amount? }

    def payment
      @bill = bills.find(params[:id])
      @receipts = candidate_receipts
    end

    def update_payment
      @bill = bills.find(params[:id])
      if save_payment(params.require(:payment).permit(:due_date, :paid_on, :receipt_id))
        redirect_to finance_documents_path(month: @bill.competence),
                    notice: t('app.messages.finance_payment_saved')
      else
        @receipts = candidate_receipts
        render :payment, status: :unprocessable_entity
      end
    end

    private

    def bills
      editable.where(kind: 'bill')
    end

    def receipts
      documents.where(kind: 'payment_receipt')
    end

    # Without a payment date, the receipt's date is when it was paid.
    def save_payment(fields)
      receipt = fields[:receipt_id].presence && receipts.find(fields[:receipt_id])
      Db::FinanceDocument.transaction do
        link(receipt)
        @bill.assign_attributes(due_date: fields[:due_date],
                                paid_on: fields[:paid_on].presence || receipt&.document_date)
        file_in_paid_month
        @bill.save!
      end
    end

    # A bill belongs to the month it was paid, which is when it shows in the statement and the
    # S-26 (S-27b par. 20), even when it was due the month after.
    def file_in_paid_month
      month = Competence.month(@bill.paid_on)
      if month && month != @bill.competence
        @bill.competence = month
        @bill.drive_url = move_in_drive(@bill, name: @bill.drive_name)[:web_view_link]
      end
    rescue GoogleDrive::Client::Error => exception
      flash.now[:alert] = "O Drive recusou a mudança: #{exception.message}"
      raise ActiveRecord::Rollback # nothing saved: the transaction returns nil
    end

    def link(receipt)
      @bill.payments.where.not(id: receipt&.id).find_each { |payment| payment.update!(bill: nil) }
      receipt&.update!(bill: @bill)
    end

    # ponytail: receipts filed up to two months around the bill; widen if bills get paid later.
    def candidate_receipts
      month = Date.parse("#{@bill.competence || Competence.month(Date.current)}-01")
      range = Competence.month(month - 2.months)..Competence.month(month + 2.months)
      receipts.where(competence: range, bill_id: [nil, @bill.id])
        .sort_by { |receipt| [same_amount?(receipt) ? 0 : 1, receipt.document_date || month] }
    end

    def same_amount?(receipt)
      receipt.amount_cents.present? && receipt.amount_cents == @bill.amount_cents
    end
  end
end
