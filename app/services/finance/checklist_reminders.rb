# frozen_string_literal: true

module Finance
  # Nudges in the finance group about what the month checklist is missing: on meeting days, the
  # S-24s of the last week's meetings; on a few days of the month, the documents (and audit
  # report) of the month that ended.
  class ChecklistReminders
    WEEK = 7
    MONTHLY_DAYS = [5, 10, 15, 20].freeze
    WEEKDAYS = %w[dom seg ter qua qui sex sáb].freeze

    def initialize(account:, telegram:)
      @account = account
      @telegram = telegram
    end

    def remind_meetings(today: Date.current)
      send_lines(meetings(today))
    end

    def remind_month(today: Date.current)
      send_lines(monthly(today))
    end

    private

    def send_lines(lines)
      if lines.any?
        @telegram.send_message(chat_id: @account.finance_telegram_chat_id,
                               text: ['📋 Faltando nas contas', *lines].join("\n"))
      end
    end

    def meetings(today)
      week = (today - WEEK)..(today - 1)
      missing_meetings(week).map do |date|
        "• S-24 de #{WEEKDAYS[date.wday]} #{date.strftime('%d/%m')}"
      end
    end

    # A week can span two months.
    def missing_meetings(week)
      dates = week.map { |day| Competence.month(day) }.uniq.flat_map do |month|
        MonthChecklist.new(account: @account, month:, today: week.last).items
          .select { |item| item.kind == 's24' && !item.done }.map(&:date)
      end
      dates.select { |date| week.cover?(date) }
    end

    def monthly(today)
      if MONTHLY_DAYS.include?(today.day)
        month = Competence.month(today.prev_month)
        MonthChecklist.new(account: @account, month:, today:).items
          .reject { |item| item.kind == 's24' || item.done }
          .map { |item| "• #{Naming::LABELS.fetch(item.kind)} de #{month}" }
      else
        []
      end
    end
  end
end
