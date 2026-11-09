# frozen_string_literal: true

module Finance
  # What the accounts archive asks for, from the elders' instructions (S-27b of February 2026,
  # Pastoreiem and its addendum, S-147 letters): audits still to do, and the standing rules on
  # what to keep and what to destroy.
  class ArchiveReminders
    Reminder = Struct.new(:title, :source, :link, keyword_init: true)
    RETENTION_YEARS = 7
    RULES = [
      Reminder.new(title: 'O original do S-24 fica com o secretário; o servo de contas guarda ' \
                          'uma cópia impressa ou digital (a foto no Drive)',
                   source: 'S-27b par. 12'),
      Reminder.new(title: 'O S-25b fica no último mês do período: fevereiro, maio, agosto ou ' \
                          'novembro',
                   source: 'S-27b par. 53 e 54'),
      Reminder.new(title: 'Os meses auditados vão para o Arquivo das contas',
                   source: 'S-27b par. 52', link: :archive),
      Reminder.new(title: "Os registros ficam #{RETENTION_YEARS} anos; os anciãos decidem se em " \
                          'papel ou eletrônico',
                   source: 'S-27b apêndice F, item 2'),
      Reminder.new(title: 'Em janeiro, verificar o arquivo e eliminar o que passou do prazo',
                   source: 'Pastoreiem adendo 14:6; S-147 de janeiro de 2026 par. 19')
    ].freeze

    def initialize(account:, today: Date.current)
      @account = account
      @today = today
    end

    # ponytail: nothing records that a reminder was done; it goes away when the S-25b arrives
    # (audits) or when January ends (archive review).
    def due
      pending_audits + (@today.month == 1 ? [archive_review] : [])
    end

    def rules
      [destroy_s24s, *RULES]
    end

    private

    def pending_audits
      first = last_audit&.next_month || first_month
      ends = first ? audit_ends(from: first) : []
      ends.map do |last|
        Reminder.new(title: "Fazer a auditoria de #{period(last)}", source: 'S-27b par. 53 e 54')
      end
    end

    # Last months of the periods that start at +from+ or later and ended before today.
    def audit_ends(from:)
      last = from >> ((Competence::AUDIT_MONTHS.first - from.month) % 3)
      ends = []
      while last.end_of_month < @today
        ends << last
        last >>= 3
      end
      ends
    end

    def archive_review
      year = @today.year - RETENTION_YEARS - 1
      count = documents.where(competence: ...format('%04d-01', year + 1)).count
      Reminder.new(title: "Verificar o arquivo e eliminar os registros de #{year} e antes" \
                          "#{in_system(count)}",
                   source: 'S-27b apêndice F, item 2; Pastoreiem adendo 14:6')
    end

    def in_system(count)
      if count.positive?
        " (#{count} #{count == 1 ? 'documento' : 'documentos'} no sistema)"
      else
        ''
      end
    end

    def destroy_s24s
      what = last_audit ? "de #{period(last_audit)}" : 'dos três meses auditados'
      Reminder.new(title: "Destruir os S-24 em papel do secretário #{what}",
                   source: 'S-27b par. 55; antes, confirmar que as fotos estão no Drive')
    end

    def period(last)
      first = last << 2
      start = first.year == last.year ? month_name(first) : "#{month_name(first)} de #{first.year}"
      "#{start} a #{month_name(last)} de #{last.year}"
    end

    def month_name(date)
      I18n.l(date, format: '%B')
    end

    def last_audit
      @last_audit ||= month_date(documents.where(kind: 'audit_report').maximum(:competence))
    end

    def first_month
      month_date(documents.minimum(:competence))
    end

    def month_date(competence)
      competence && Date.parse("#{competence}-01")
    end

    def documents
      @account.finance_documents.where(state: 'archived')
    end
  end
end
