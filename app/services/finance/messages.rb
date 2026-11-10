# frozen_string_literal: true

module Finance
  # Bot copy shown in the Telegram group.
  module Messages # rubocop:disable Metrics/ModuleLength -- all bot copy in one place
    ORIGINS = { 'ai' => 'lido por IA', 'rules' => 'lido do PDF', 'human' => 'informado' }.freeze
    NOT_A_CONFIRMER = 'Só quem confirma as contas pode usar estes botões.'
    NOT_A_CASH_RECEIVER = 'Só o servo de contas, um ajudante ou o responsável pelas contas pode ' \
                          'marcar que recebeu o dinheiro.'
    NOT_AN_EDITOR = 'Só quem enviou o arquivo ou quem confirma as contas pode corrigir.'
    ALREADY_WITH_YOU = 'Já está com você.'
    CORRECTED = '✏️ Corrigido. Confira a sugestão acima e confirme.'
    ARCHIVING = 'Arquivando…'
    DISCARDED = 'Ignorado (não é das contas).'
    ARCHIVE_FAILED = 'Não consegui arquivar agora; vou tentar de novo.'
    NEEDS_MONTH = 'Falta o mês: use ✏️ Corrigir antes de confirmar.'
    ALREADY_HANDLED = 'Este documento já foi tratado.'
    UNREADABLE = 'Não consegui ler este arquivo. Envie de novo ou arquive à mão.'
    REPLACES = '⚠️ Substitui o arquivo já arquivado ' \
               '(a versão anterior fica no histórico do Drive)'
    EDIT_PROMPT = 'Responda a esta mensagem com os campos a mudar, por exemplo: ' \
                  "data 2026-11-05 local 120 mundial 30\nCampos: %{keys}\n" \
                  'Ou diga com suas palavras, por escrito ou num áudio: ' \
                  '"é a auditoria de março a maio".'
    LISTENING = '🎧 Entendendo a correção…'
    NEEDS_AI = 'Para entender áudios e frases, cadastre a chave da OpenAI nas integrações. ' \
               'Ou responda com os campos, por exemplo: local 120 mundial 30'

    module_function

    # With what was said in plain words, so whoever corrected can check what was understood.
    def corrected(heard: nil)
      if heard
        "✏️ Corrigido.\n#{heard}\nConfira a sugestão acima e confirme."
      else
        CORRECTED
      end
    end

    def suggestion(document:)
      [suggestion_text(document), buttons(document)]
    end

    def suggestion_text(document)
      [
        "#{Naming.filename(document:)} → Arquivo Corrente/#{document.competence || '?'}/",
        s24_split(document),
        s24_total_mismatch(document),
        ORIGINS[document.value_source] && "(#{ORIGINS[document.value_source]})",
        document.flagged?(:encrypted_original) && '⚠️ PDF com senha: não consegui abrir',
        missing?(document) && 'Não consegui ler tudo: use ✏️ Corrigir.',
        document.replaced_document && REPLACES
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
    def archived(document:, replaced: false)
      verb = replaced ? 'Substituído' : 'Arquivado'
      ["#{verb}: #{drive_link(document)} → Arquivo Corrente/#{document.competence}/",
       edit_link(document)].compact.join("\n")
    end

    # The edit page in khtools; APP_URL is set in config/deploy.yml (none in development).
    def edit_link(document)
      if ENV['APP_URL'].present?
        url = "#{ENV['APP_URL'].delete_suffix('/')}/finance/documents/#{document.id}/edit"
        %(✏️ <a href="#{CGI.escapeHTML(url)}">Corrigir no khtools</a>)
      end
    end

    def drive_link(document)
      url = CGI.escapeHTML(document.drive_url)
      %(<a href="#{url}">#{CGI.escapeHTML(document.drive_name)}</a>)
    end

    WEEKDAYS = %w[dom seg ter qua qui sex sáb].freeze

    # The cash of an S-24 stays with whoever counted it until the accounts servant or a helper
    # gets it.
    def cash(document)
      date = document.document_date
      day = date && "#{WEEKDAYS[date.wday]} #{date.strftime('%d/%m')}"
      what = "💵 Dinheiro do S-24 de #{day} (#{Money.format(cents: document.amount_cents.to_i)})"
      holder = if document.cash_received_at
                 "Entregue a: #{document.cash_received_by}"
               else
                 "Está com: #{document.cash_holder_name}#{creditor_note(document)}"
               end
      pix = document.cash_pix_at ? "Pix: feito por #{document.cash_pix_by}" : 'Pix: pendente'
      [what, holder, pix].join("\n")
    end

    def creditor_note(document)
      if document.cash_creditor
        " (entregar a #{document.cash_creditor}, que fez o Pix)"
      end
    end

    def cash_buttons(document)
      rows = []
      unless document.cash_received_at
        rows << [['🙋 Está comigo', "fin:cash_holder:#{document.id}"],
                 ['✅ Recebi', "fin:cash_received:#{document.id}"]]
      end
      unless document.cash_pix_at
        rows << [['💸 Fiz o Pix', "fin:cash_pix:#{document.id}"]]
      end
      rows.presence
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

    # People have added the S-24 up wrong before; the split is what gets archived.
    def s24_total_mismatch(document)
      written = document.written_total_cents
      sum = document.congregation_cents.to_i + document.worldwide_cents.to_i
      if document.kind == 's24' && written && written != sum
        "⚠️ Total escrito no recibo (#{Money.format(cents: written)}) " \
          "não confere com a soma (#{Money.format(cents: sum)})"
      end
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
