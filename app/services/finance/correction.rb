# frozen_string_literal: true

module Finance
  # Applies a human correction such as "local 120 mundial 30 data 2026-11-05".
  module Correction
    class Error < StandardError; end

    KEYS = %w[tipo data valor local mundial mes desc].freeze

    module_function

    def apply(document:, text:)
      fields = parse(text)
      fields.each { |key, value| assign(document, key, value) }
      sum_s24(document) if document.kind == 's24' && fields.keys.intersect?(%w[local mundial])
      refresh_competence(document) if !fields.key?('mes') && fields.keys.intersect?(%w[tipo data])
      document.value_source = 'human'
      document
    end

    def sum_s24(document)
      document.amount_cents = document.congregation_cents.to_i + document.worldwide_cents.to_i
    end

    def parse(text)
      tokens = text.to_s.split
      if tokens.empty?
        raise Error, "Diga o que mudar. Campos: #{KEYS.join(', ')}"
      end

      group(tokens).transform_values { |words| words.join(' ') }
    end

    def group(tokens)
      key = nil
      tokens.each_with_object({}) do |token, fields|
        if key != 'desc' && KEYS.include?(normalize(token))
          key = normalize(token)
          fields[key] = []
        else
          fields.fetch(key) { raise Error, unknown_field(token) } << token
        end
      end
    end

    def unknown_field(token)
      "Campo desconhecido: #{token}. Campos: #{KEYS.join(', ')}"
    end

    def normalize(token)
      token.downcase.sub('mês', 'mes')
    end

    def assign(document, key, value)
      case key
      when 'tipo' then document.kind = kind(value)
      when 'data' then document.document_date = date(value)
      when 'mes' then document.competence = month(value)
      when 'desc' then document.description = value.presence
      else assign_cents(document, key, value)
      end
    end

    CENTS_ATTRIBUTES = {
      'valor' => :amount_cents, 'local' => :congregation_cents, 'mundial' => :worldwide_cents
    }.freeze

    def assign_cents(document, key, value)
      attribute = CENTS_ATTRIBUTES[key]
      document[attribute] = cents(value, key) if attribute
    end

    def kind(value)
      Naming::LABELS.find do |kind, label|
        [kind, label.downcase].include?(value.downcase)
      end&.first ||
        raise(Error, "tipo inválido: #{value}. Tipos: #{Naming::LABELS.values.join(', ')}")
    end

    def date(value)
      case value
      when /\A\d{4}-\d{2}-\d{2}\z/ then Date.iso8601(value)
      when %r{\A\d{2}/\d{2}/\d{4}\z} then Date.strptime(value, '%d/%m/%Y')
      else raise Error, "data inválida: #{value} (use 2026-11-05 ou 05/11/2026)"
      end
    rescue Date::Error
      raise Error, "data inválida: #{value}"
    end

    def cents(value, key)
      (value.match?(/\d/) && Money.parse(text: value)) || raise(Error, "#{key} inválido: #{value}")
    end

    def month(value)
      if value.match?(/\A\d{4}-(0[1-9]|1[0-2])\z/)
        value
      else
        raise(Error,
              "mes inválido: #{value} (use 2026-10)")
      end
    end

    def refresh_competence(document)
      monthly = Competence::MONTHLY.include?(document.kind)
      document.assign_competence(period: monthly ? document.competence : nil)
    end
  end
end
