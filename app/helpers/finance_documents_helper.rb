# frozen_string_literal: true

# Who sent, confirmed and corrected a finance document, and when: on the list's history icon
# and on the edit page.
module FinanceDocumentsHelper
  def finance_document_history(document)
    [sent_line(document), confirmed_line(document),
     *document.corrections.map { |correction| correction_line(correction) }].compact
  end

  private

  def sent_line(document)
    if document.sent_by_name.present?
      "Enviado por #{document.sent_by_name} em #{history_time(document.created_at)}"
    elsif document.backfilled?
      'Já estava no Drive'
    end
  end

  def confirmed_line(document)
    if document.confirmed_by.present?
      when_text = document.confirmed_at ? " em #{history_time(document.confirmed_at)}" : ''
      "Confirmado por #{document.confirmed_by}#{when_text}"
    end
  end

  def correction_line(correction)
    "Corrigido por #{correction['by_name']} em " \
      "#{history_time(Time.zone.parse(correction['at'].to_s))}: #{correction['text']}"
  end

  def history_time(time)
    time && l(time, format: '%d/%m/%Y às %H:%M')
  end
end
