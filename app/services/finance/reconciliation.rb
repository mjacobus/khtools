# frozen_string_literal: true

module Finance
  # Checks a month's archived documents against the bank statement, the way the S-26 does
  # (S-27b par. 27-34): each statement line gets the document that explains it, and two
  # balances that must agree come out:
  # - expected: opening + S-24s + electronic donations + interest - receipts - remittance;
  # - confronto: statement balance + S-24s not yet deposited - remittance not yet sent.
  class Reconciliation
    Entry = Struct.new(:line, :reason, :document)

    DEPOSIT_DAYS = 7
    EXPENSE_DAYS = 5
    REMITTANCE_DAYS = 20

    attr_reader :entries, :opening_cents

    def initialize(account:, month:, lines:, holder:, opening_cents:)
      @first = Date.parse("#{month}-01")
      @month = month
      @holder = holder.to_s
      @opening_cents = opening_cents
      @documents = documents(account)
      @used = []
      @lines = until_month_end(lines)
      @entries = @lines.map { |line| explain(line) }.select { |entry| entry.line.date >= @first }
    end

    def undeposited = left_over('s24')
    def unpaid = left_over('payment_receipt')
    def pending_remittances = left_over('remittance_record')

    def statement_cents
      @lines.last&.balance_cents
    end

    def confronto_cents
      statement_cents.to_i + sum(undeposited) - sum(pending_remittances)
    end

    def expected_cents
      if opening_cents
        opening_cents + sum(of('s24')) + lines_sum(:donation, :interest) -
          sum(of('payment_receipt')) - sum(of('remittance_record'))
      end
    end

    def difference_cents
      expected_cents && (expected_cents - confronto_cents)
    end

    private

    def last_day = @first.end_of_month

    def until_month_end(lines)
      lines.select { |line| line.date <= last_day }
        .sort_by.with_index { |line, index| [line.date, index] }
    end

    # Last month's too: its S-24s are deposited and its remittance goes out in this one.
    def documents(account)
      account.finance_documents.where(state: 'archived')
        .where(competence: [Competence.month(@first.prev_month), @month])
        .order(:document_date).to_a
    end

    def explain(line)
      line.cents.positive? ? credit(line) : debit(line)
    end

    def credit(line)
      s24 = pick('s24', line.cents) { |date| (0..DEPOSIT_DAYS).cover?(line.date - date) }
      if s24
        Entry.new(line, :deposit, s24)
      elsif line.who.nil?
        Entry.new(line, :interest)
      else
        Entry.new(line, holder?(line.who) ? :unexplained_deposit : :donation)
      end
    end

    def debit(line)
      remittance = pick('remittance_record', -line.cents) do |date|
        (0..REMITTANCE_DAYS).cover?(line.date - date)
      end
      remittance ? Entry.new(line, :remittance, remittance) : expense(line)
    end

    def expense(line)
      receipt = pick('payment_receipt', -line.cents) do |date|
        (line.date - date).abs <= EXPENSE_DAYS
      end
      Entry.new(line, receipt ? :expense : :unexplained, receipt)
    end

    # ponytail: first same-amount document in the date window; two equal amounts close together
    # can swap, which only matters if one of them is missing.
    def pick(kind, cents)
      found = @documents.find do |document|
        document.kind == kind && document.amount_cents == cents && @used.exclude?(document) &&
          document.document_date && yield(document.document_date)
      end
      @used << found if found
      found
    end

    # Pix from the account holder is cash being deposited; REM shows a truncated name.
    def holder?(who)
      @holder.present? && (@holder.start_with?(who) || who.start_with?(@holder))
    end

    def of(kind)
      @documents.select { |document| document.kind == kind && document.competence == @month }
    end

    def left_over(kind)
      of(kind) - @used
    end

    def lines_sum(*reasons)
      entries.select { |entry| reasons.include?(entry.reason) }.sum { |entry| entry.line.cents }
    end

    def sum(documents)
      documents.sum { |document| document.amount_cents.to_i }
    end
  end
end
