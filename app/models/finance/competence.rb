# frozen_string_literal: true

module Finance
  module Competence
    MONTHLY = %w[statement betel_statement s26 s30 thank_you_letter audit_report].freeze
    REMITTANCE = %w[remittance_record remittance_receipt].freeze

    module_function

    # Bills start in their own month; marking one paid in khtools moves it to the month it was
    # paid (Finance::BillPayments).
    def default_for(kind:, document_date:, period:)
      if MONTHLY.include?(kind)
        return period.presence || month(document_date)
      end
      unless document_date
        return nil
      end
      if REMITTANCE.include?(kind) && document_date.day <= 10
        return month(document_date.prev_month)
      end

      month(document_date)
    end

    def remittance_date(competence:)
      Date.parse("#{competence}-01").end_of_month
    end

    def month(date)
      date&.strftime('%Y-%m')
    end
  end
end
