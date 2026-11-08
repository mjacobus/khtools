# frozen_string_literal: true

module Finance
  module Naming
    LABELS = {
      's24' => 'S-24',
      'payment_receipt' => 'Comprovante',
      'bill' => 'Fatura',
      'statement' => 'Extrato',
      'betel_statement' => 'Extrato Betel',
      's26' => 'S-26',
      's30' => 'S-30',
      'remittance_record' => 'Remessa Betel TO-62',
      'remittance_receipt' => 'Comprovante Remessa Betel',
      'thank_you_letter' => 'Carta de agradecimento Betel',
      'audit_report' => 'S-25b',
      'unknown' => 'Documento'
    }.freeze

    module_function

    def filename(document:)
      title = [LABELS.fetch(document.kind), document.description.presence].compact.join(' ')
      parts = if Competence::MONTHLY.include?(document.kind)
                [document.competence, title]
              else
                [document.document_date&.iso8601, amount(document), title]
              end
      "#{parts.compact.join(' - ')}#{extension(document)}"
    end

    def folder_path(document:)
      ['Arquivo Corrente', document.competence]
    end

    def amount(document)
      document.amount_cents && Money.format(cents: document.amount_cents)
    end

    def extension(document)
      ext = File.extname(document.original_filename.to_s).downcase
      if ext.present?
        return ext
      end

      document.mime_type == 'application/pdf' ? '.pdf' : '.jpg'
    end
  end
end
