# frozen_string_literal: true

module Finance
  module Money
    module_function

    def format(cents:)
      reais, centavos = cents.divmod(100)
      "R$ #{reais.to_s.reverse.scan(/\d{1,3}/).join('.').reverse},#{centavos.to_s.rjust(2, '0')}"
    end

    def parse(text:)
      match = text.to_s.match(/(\d{1,3}(?:\.\d{3})+|\d+)(?:,(\d{1,2}))?/)
      return nil unless match

      (match[1].delete('.').to_i * 100) + match[2].to_s.ljust(2, '0').to_i
    end
  end
end
