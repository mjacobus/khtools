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
      save_payment(params.require(:payment).permit(:due_date, :paid_on, :receipt_id))
      redirect_to finance_documents_path(month: @bill.competence),
                  notice: t('app.messages.finance_payment_saved')
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
        @bill.update!(due_date: fields[:due_date],
                      paid_on: fields[:paid_on].presence || receipt&.document_date)
      end
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
