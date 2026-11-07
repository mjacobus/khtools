# frozen_string_literal: true

module Finance
  # What a month of accounts should have: one S-24 per meeting (Wednesdays and Saturdays,
  # minus the exceptions), the monthly documents, and the audit report in the last month of
  # each audited quarter (S-27b par. 50 and 54).
  class MonthChecklist
    # ponytail: the congregation's meeting days; an account setting when another one needs it.
    MEETING_DAYS = [3, 6].freeze # Wednesday, Saturday
    MONTHLY = %w[statement s26 s30 remittance_record remittance_receipt].freeze
    AUDIT_MONTHS = [2, 5, 8, 11].freeze # quarters Dec-Feb, Mar-May, Jun-Aug, Sep-Nov
    Item = Struct.new(:kind, :date, :done, keyword_init: true)

    def initialize(account:, month:, today: Date.current)
      @account = account
      @first = Date.parse("#{month}-01")
      @today = today
    end

    def items
      meetings + monthly
    end

    private

    def meetings
      dated = documents.where(kind: 's24').pluck(:document_date).to_set
      meeting_dates.map { |date| Item.new(kind: 's24', date:, done: dated.include?(date)) }
    end

    def meeting_dates
      until_today = @first..[@first.end_of_month, @today].min
      days = until_today.select { |day| MEETING_DAYS.include?(day.wday) }
      exceptions = @account.finance_meeting_exceptions
      skipped = exceptions.where(date: @first..@first.end_of_month).pluck(:date)
      moved = exceptions.where(moved_to: until_today).pluck(:moved_to)
      (days - skipped + moved).sort
    end

    def monthly
      kinds = MONTHLY + (AUDIT_MONTHS.include?(@first.month) ? ['audit_report'] : [])
      present = documents.where(kind: kinds, competence: Competence.month(@first))
        .distinct.pluck(:kind)
      kinds.map { |kind| Item.new(kind:, done: present.include?(kind)) }
    end

    # Only what is filed in Drive counts (not a suggestion waiting for confirmation, nor a file
    # deleted there). S-24s are found by their date, wherever they were filed.
    def documents
      @account.finance_documents.where(state: 'archived')
        .where("COALESCE(flags, '') NOT LIKE ?", '%trashed%')
    end
  end
end
