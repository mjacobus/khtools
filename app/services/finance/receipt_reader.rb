# frozen_string_literal: true

module Finance
  # Reads a photo of form S-24 with Claude vision. Returns nil whenever the answer
  # can't be trusted to be well-formed; a human confirms every value anyway.
  class ReceiptReader
    MODEL = :'claude-opus-5-5'
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

    def initialize(api_key:, client: nil)
      @client = client || Anthropic::Client.new(api_key:)
    end

    def read(image_bytes:, mime_type:)
      message = @client.messages.create(**request(image_bytes, mime_type))
      if message.stop_reason == :refusal
        return log_nil('refused')
      end

      parse(message.content.find { |block| block.type == :text }&.text)
    rescue Anthropic::Errors::Error, JSON::ParserError => exception
      log_nil("#{exception.class}: #{exception.message}")
    end

    private

    def parse(text)
      Result.new(**JSON.parse(text.to_s).slice(*Result.members.map(&:to_s)).symbolize_keys)
    end

    def request(image_bytes, mime_type)
      image = { type: :base64, media_type: mime_type, data: Base64.strict_encode64(image_bytes) }
      {
        model: MODEL,
        max_tokens: 1024,
        messages: [{ role: :user,
                     content: [{ type: :image, source: image }, { type: :text, text: PROMPT }] }],
        output_config: { format: { type: :json_schema, schema: SCHEMA } }
      }
    end

    def log_nil(reason)
      Rails.logger.warn("[finance] S-24 reader gave up: #{reason}")
      nil
    end
  end
end
