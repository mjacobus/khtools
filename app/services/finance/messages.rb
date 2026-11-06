# frozen_string_literal: true

module Finance
  # Bot copy shown in the Telegram group.
  module Messages
    ORIGINS = { 'ai' => 'lido por IA', 'rules' => 'lido do PDF', 'human' => 'informado' }.freeze
    NOT_A_CONFIRMER = 'Só quem confirma as contas pode usar estes botões.'
    ARCHIVING = 'Arquivando…'
    DISCARDED = 'Ignorado (não é das contas).'
    ARCHIVE_FAILED = 'Não consegui arquivar agora; vou tentar de novo.'
    NEEDS_MONTH = 'Falta o mês: use ✏️ Corrigir antes de confirmar.'
    ALREADY_HANDLED = 'Este documento já foi tratado.'
    UNREADABLE = 'Não consegui ler este arquivo. Envie de novo ou arquive à mão.'
    EDIT_PROMPT = 'Responda a esta mensagem com os campos a mudar, por exemplo: ' \
                  "data 2026-11-05 local 120 mundial 30\nCampos: %{keys}"

    module_function

    def suggestion(document:)
      [suggestion_text(document), buttons(document)]
    end

    def suggestion_text(document)
      [
        "#{Naming.filename(document:)} → Arquivo Corrente/#{document.competence || '?'}/",
        s24_split(document),
        ORIGINS[document.value_source] && "(#{ORIGINS[document.value_source]})",
        document.flagged?(:encrypted_original) && '⚠️ PDF com senha: não consegui abrir',
        missing?(document) && 'Não consegui ler tudo: use ✏️ Corrigir.'
      ].select(&:present?).join("\n")
    end

    def buttons(document)
      [[['✅ Confirmar', "fin:confirm:#{document.id}"], ['✏️ Corrigir', "fin:edit:#{document.id}"],
        ['🗑️ Não é das contas', "fin:discard:#{document.id}"]]]
    end

    # HTML (parse_mode): the file name links to the archived file on Drive.
    def duplicate(original:)
      if original.drive_url.blank?
        'Este arquivo já foi enviado antes.'
      else
        "Este arquivo já foi arquivado: #{drive_link(original)}"
      end
    end

    # HTML (parse_mode), like duplicate.
    def archived(document:)
      "Arquivado: #{drive_link(document)} → Arquivo Corrente/#{document.competence}/"
    end

    def drive_link(document)
      url = CGI.escapeHTML(document.drive_url)
      %(<a href="#{url}">#{CGI.escapeHTML(Naming.filename(document:))}</a>)
    end

    def edit_prompt
      format(EDIT_PROMPT, keys: Correction::KEYS.join(', '))
    end

    def s24_split(document)
      unless document.kind == 's24'
        return
      end
      unless document.congregation_cents || document.worldwide_cents
        return
      end

      "Congregação #{Money.format(cents: document.congregation_cents.to_i)} · " \
        "Obra mundial #{Money.format(cents: document.worldwide_cents.to_i)}"
    end

    def missing?(document)
      if document.competence.blank? || document.kind == 'unknown'
        return true
      end
      if Competence::MONTHLY.include?(document.kind)
        return false
      end

      document.document_date.nil? || document.amount_cents.nil?
    end
  end
end
