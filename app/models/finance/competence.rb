# frozen_string_literal: true

module Finance
  module Competence
    MONTHLY = %w[statement s26 s30 thank_you_letter audit_report].freeze
    REMITTANCE = %w[remittance_record remittance_receipt].freeze

    module_function

    # ponytail: bills stay in their due month; moving them to the payment month needs
    # bill<->payment matching (next plan).
    def default_for(kind:, document_date:, period:)
      return period.presence || month(document_date) if MONTHLY.include?(kind)
      return nil unless document_date
      return month(document_date.prev_month) if REMITTANCE.include?(kind) && document_date.day <= 10

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
