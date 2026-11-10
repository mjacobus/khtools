# frozen_string_literal: true

module Finance
  # The month's donations from the filed S-24s, and what goes to Betel: the worldwide work
  # donations plus the monthly resolution (S-27b par. 22 and 26).
  class MonthSummary
    def initialize(account:, month:)
      @account = account
      @month = month
    end

    def worldwide_cents
      s24s.sum(:worldwide_cents)
    end

    def local_cents
      s24s.sum(:congregation_cents)
    end

    # ponytail: one current value; past months use it too until it is kept per service year.
    def resolution_cents
      @account.finance_resolution_cents.to_i
    end

    def remittance_cents
      worldwide_cents + resolution_cents
    end

    # What the filed TO-62 says was sent, if it is filed.
    def remitted_cents
      documents.where(kind: 'remittance_record').sum(:amount_cents).nonzero?
    end

    private

    def s24s
      documents.where(kind: 's24')
    end

    def documents
      @account.finance_documents.where(state: 'archived', competence: @month)
    end
  end
end
