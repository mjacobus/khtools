# frozen_string_literal: true

module Finance
  module Competence
    MONTHLY = %w[statement betel_statement s26 s30 thank_you_letter audit_report].freeze
    REMITTANCE = %w[remittance_record remittance_receipt].freeze
    # Audit periods end in these months, where the S-25b is filed (S-27b par. 53-54).
    AUDIT_MONTHS = [2, 5, 8, 11].freeze # Dec-Feb, Mar-May, Jun-Aug, Sep-Nov

    module_function

    # Bills start in their own month; marking one paid in khtools moves it to the month it was
    # paid (Finance::BillPayments).
    def default_for(kind:, document_date:, period:)
      case kind
      when 'audit_report'
        period.presence || (document_date && last_audit_month(before: document_date))
      when *MONTHLY then period.presence || month(document_date)
      when *REMITTANCE then remittance_month(document_date)
      else month(document_date)
      end
    end

    def remittance_month(date)
      if date && date.day <= 10
        month(date.prev_month)
      else
        month(date)
      end
    end

    # The audit is made after its period ends, so its report belongs to an earlier month:
    # the last audit month (Feb, May, Aug, Nov) before the given date's month.
    def last_audit_month(before:)
      date = before.prev_month
      month(date << ((date.month - 2) % 3))
    end

    def audit_month?(competence)
      AUDIT_MONTHS.include?(competence.to_s[5, 2].to_i)
    end

    # nil when the S-25b may be filed in that month.
    def audit_month_error(competence)
      if competence.to_s.match?(/\A\d{4}-\d{2}\z/) && !audit_month?(competence)
        "#{competence} não é o último mês de um período de auditoria. O S-25b fica em " \
          'fevereiro, maio, agosto ou novembro (S-27b par. 54): use ' \
          "#{last_audit_month(before: Date.parse("#{competence}-01").next_month)}."
      end
    end

    def remittance_date(competence:)
      Date.parse("#{competence}-01").end_of_month
    end

    def month(date)
      date&.strftime('%Y-%m')
    end
  end
end
