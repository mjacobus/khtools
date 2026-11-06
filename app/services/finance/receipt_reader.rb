# frozen_string_literal: true

module Finance
  # Reads a photo of form S-24 with OpenAI vision. Returns nil whenever the answer
  # can't be trusted to be well-formed; a human confirms every value anyway.
  class ReceiptReader
    URL = URI('https://api.openai.com/v1/responses')
    MODEL = 'gpt-6-luna'
    Result = Struct.new(:is_s24, :date, :congregation_cents, :worldwide_cents, keyword_init: true)

    PROMPT = <<~TEXT
      Esta é a foto de um formulário S-24 "Recibo" de donativos de uma congregação.
      Leia a data do recolhimento e os valores escritos em "Despesas da congregação local"
      e "Obra mundial". Informe os valores em centavos (R$ 120,00 = 12000).
      Se um valor estiver em branco, use 0. Se a data não estiver legível, use "".
      Se a foto não for de um S-24, responda is_s24 = false.
      Não transcreva nomes nem assinaturas.
    TEXT

    SCHEMA = {
      type: 'object',
      properties: {
        is_s24: { type: 'boolean' },
        date: { type: 'string', description: 'YYYY-MM-DD ou vazio' },
        congregation_cents: { type: 'integer' },
        worldwide_cents: { type: 'integer' }
      },
      required: %w[is_s24 date congregation_cents worldwide_cents],
      additionalProperties: false
    }.freeze

    def initialize(api_key:)
      @api_key = api_key
    end

    def read(image_bytes:, mime_type:)
      response = Net::HTTP.post(URL, request(image_bytes, mime_type).to_json,
                                'Content-Type' => 'application/json',
                                'Authorization' => "Bearer #{@api_key}")
      if response.is_a?(Net::HTTPSuccess)
        parse(JSON.parse(response.body))
      else
        log_nil("HTTP #{response.code}: #{response.body.to_s.truncate(300)}")
      end
    rescue StandardError => exception
      log_nil("#{exception.class}: #{exception.message}")
    end

    private

    # Reasoning models put a reasoning item before the message; a refusal has no output_text.
    def parse(body)
      content = body['output'].to_a.flat_map { |item| item['content'].to_a }
      text = content.find { |part| part['type'] == 'output_text' }&.dig('text')
      if text
        result(JSON.parse(text))
      else
        log_nil("no answer: #{content.to_json.truncate(300)}")
      end
    end

    def result(values)
      Result.new(**values.slice(*Result.members.map(&:to_s)).symbolize_keys)
    end

    def request(image_bytes, mime_type)
      image = "data:#{mime_type};base64,#{Base64.strict_encode64(image_bytes)}"
      {
        model: MODEL,
        input: [{ role: 'user', content: [{ type: 'input_image', image_url: image },
                                          { type: 'input_text', text: PROMPT }] }],
        text: { format: { type: 'json_schema', name: 's24', schema: SCHEMA, strict: true } }
      }
    end

    def log_nil(reason)
      Rails.logger.warn("[finance] S-24 reader gave up: #{reason}")
      nil
    end
  end
end
