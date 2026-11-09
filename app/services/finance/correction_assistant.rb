# frozen_string_literal: true

module Finance
  # Understands a correction said in plain words ("é a auditoria de março a maio"), typed or
  # in a voice message, and turns it into the fields Finance::Correction applies. The
  # correction is still validated there, and a human still confirms the suggestion.
  class CorrectionAssistant
    TRANSCRIPTIONS_URL = URI('https://api.openai.com/v1/audio/transcriptions')
    RESPONSES_URL = URI('https://api.openai.com/v1/responses')
    TRANSCRIBE_MODEL = 'gpt-transcribe'
    FIELDS = Correction::KEYS # desc is last: it takes the rest of the text

    PROMPT = <<~TEXT
      Você ajuda o servo de contas de uma congregação a corrigir os dados de um documento.
      Hoje é %{today}. Os dados atuais do documento são: %{current}.
      Ele disse: "%{text}"

      Preencha só os campos que ele quer mudar; deixe os outros como "".
      - tipo: um destes códigos: %{kinds}
      - data: a data do documento, AAAA-MM-DD
      - mes: o mês em que o documento fica no arquivo, AAAA-MM
      - valor, local (despesas da congregação), mundial (obra mundial) e total (o total
        escrito no S-24): em reais, como 120,50
      - desc: uma descrição curta, como "Luz" ou "Água"
      O S-25b (audit_report) de uma auditoria fica no último mês do período auditado:
      fevereiro, maio, agosto ou novembro. Por exemplo, a auditoria de março a maio de
      2026 é tipo audit_report, mes 2026-05. Sem ano, use o período mais recente que já terminou.
    TEXT

    SCHEMA = {
      type: 'object',
      properties: FIELDS.index_with { |_field| { type: 'string' } },
      required: FIELDS,
      additionalProperties: false
    }.freeze

    def initialize(api_key:)
      @api_key = api_key
    end

    def transcribe(audio:)
      request = Net::HTTP::Post.new(TRANSCRIPTIONS_URL, 'Authorization' => "Bearer #{@api_key}")
      request.set_form([['file', StringIO.new(audio), { filename: 'audio.ogg' }],
                        ['model', TRANSCRIBE_MODEL], %w[language pt]], 'multipart/form-data')
      response = Net::HTTP.start(TRANSCRIPTIONS_URL.host, TRANSCRIPTIONS_URL.port,
                                 use_ssl: true) do |http|
        http.request(request)
      end
      success!(response).fetch('text')
    end

    def correction(text:, document:)
      response = Net::HTTP.post(RESPONSES_URL, request(text, document).to_json,
                                'Content-Type' => 'application/json',
                                'Authorization' => "Bearer #{@api_key}")
      fields = JSON.parse(output(success!(response)))
      correction = FIELDS.filter_map do |field|
        "#{field} #{fields[field].strip}" if fields[field].to_s.strip.present?
      end
      correction.presence&.join(' ') || raise(Correction::Error,
                                              "Não entendi o que corrigir em \"#{text}\".")
    end

    private

    def success!(response)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise Correction::Error, "A OpenAI não respondeu (HTTP #{response.code}). Tente de novo."
      end
    end

    def output(body)
      body['output'].to_a.flat_map { |item| item['content'].to_a }
        .find { |part| part['type'] == 'output_text' }&.dig('text') ||
        raise(Correction::Error, 'A OpenAI não respondeu. Tente de novo.')
    end

    def request(text, document)
      kinds = Naming::LABELS.map { |kind, label| "#{kind} (#{label})" }.join(', ')
      prompt = format(PROMPT, today: Date.current.iso8601, current: current(document).to_json,
                              text:, kinds:)
      { model: ReceiptReader::MODEL,
        input: [{ role: 'user', content: [{ type: 'input_text', text: prompt }] }],
        text: { format: { type: 'json_schema', name: 'correction', schema: SCHEMA,
                          strict: true } } }
    end

    def current(document)
      { tipo: document.kind, data: document.document_date&.iso8601, mes: document.competence,
        valor: document.amount_cents && Money.format(cents: document.amount_cents),
        desc: document.description }
    end
  end
end
