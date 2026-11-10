# frozen_string_literal: true

module Finance
  # Classifies PDF text by plain rules. Wrong guesses are fine: a human confirms
  # or corrects every suggestion before anything is archived.
  class Classifier # rubocop:disable Metrics/ClassLength
    Result = Struct.new(:kind, :document_date, :amount_cents, :description, :period,
                        keyword_init: true)

    MONTHS = %w[janeiro fevereiro março abril maio junho julho agosto setembro outubro novembro
                dezembro].freeze
    MONTH_YEAR = /\b(#{MONTHS.join('|')})(?:\s+de)?\s+(\d{4})\b/i
    LONG_DATE = /\b(\d{1,2})\s+de\s+(#{MONTHS.join('|')})\s+de\s+(\d{4})\b/i
    DATE = %r{\b(\d{2})/(\d{2})/(\d{4})\b}
    BR_MONEY = /\d{1,3}(?:\.\d{3})*,\d{2}/
    US_MONEY = /\b\d{1,3}(?:,\d{3})*\.\d{2}\b/
    MONEY = /#{BR_MONEY}|#{US_MONEY}/
    BILL_TOTAL = /TOTAL A PAGAR|TOTAL DA NOTA|TOTAL \(R\$\)|VALOR TOTAL(?! DOS)|Valor R\$/i
    ATV_CNPJ = '33.755.687/0001-24'

    # First match wins.
    RULES = [
      [/RELAT[ÓO]RIO MENSAL DE CONTAS DA CONGREGA[ÇC][ÃA]O \(S-30\)/i, :s30],
      [/Folha de Contas.*S-26|S-26.*Folha de Contas/im, :s26],
      [/REGISTRO DE TRANSFER[ÊE]NCIA DE FUNDOS|Remessas/i, :remittance_record],
      [/S-25/, :audit_report],
      [/#{Regexp.escape(ATV_CNPJ)}/, :remittance_receipt],
      [/Carta de Agradecimento/i, :thank_you_letter],
      [/Fundos mantidos em Betel|Conta da Congrega[çc][ãa]o em Betel/i, :betel_statement],
      [/Extrato/i, :statement],
      [/Comprovante de (?:transa|pagamento)|Dados do pagamento/i, :payment_receipt],
      [/Vencimento|Fatura|Boleto|Nota Fiscal|NF-e/i, :bill]
    ].freeze

    def classify(text:)
      @text = text.to_s
      rule = RULES.find { |pattern, _| @text.match?(pattern) }
      (rule && send(rule.last)) || Result.new(kind: 'unknown')
    end

    private

    def s30
      Result.new(kind: 's30', period: first_period)
    end

    def s26
      Result.new(kind: 's26', period: first_period)
    end

    def audit_report
      Result.new(kind: 'audit_report', period: last_period)
    end

    def thank_you_letter
      unless @text.match?(/obra mundial/i)
        return
      end

      Result.new(kind: 'thank_you_letter', period: letter_month)
    end

    # Filed with the remittance it lists (S-27b par. 27 and 48), like the remittance documents.
    # ponytail: the first date is the remittance's; without one, the 1st of the letter's month.
    def letter_month
      remitted = date(@text[DATE]) || first_period&.then { |month| Date.parse("#{month}-01") }
      remitted && Competence.remittance_month(remitted)
    end

    def remittance_record
      unless @text.match?(/N[úu]mero de confirma[çc][ãa]o/i)
        return
      end

      date = @text[/Data do dep[óo]sito\s+(#{LONG_DATE})/o, 1] || @text[LONG_DATE]
      amount = @text[/(?:Total\s*R\$|TOTAL DE FUNDOS ENVIADOS:)\s*(#{BR_MONEY})/io, 1]
      Result.new(kind: 'remittance_record', document_date: long_date(date),
                 amount_cents: money(amount))
    end

    def remittance_receipt
      pix('remittance_receipt')
    end

    def payment_receipt
      pix('payment_receipt', description: payee)
    end

    def pix(kind, description: nil)
      date = @text[/^\s*Data:\s*(\S+)/, 1] || @text[/Data da opera[çc][ãa]o:\s*(\S+)/, 1]
      Result.new(kind:, document_date: date(date), description:,
                 amount_cents: money(@text[/^\s*Valor:\s*([\d.,]+)/, 1]))
    end

    # The last complete month covered: banks put the previous day's balance and the
    # emission date around the month, so the latest date decides.
    def statement(kind: 'statement')
      last = @text.scan(DATE).filter_map { |day| date(day.join('/')) }.max
      if last && last != last.end_of_month
        last = last.prev_month
      end
      Result.new(kind:, period: last&.strftime('%Y-%m'))
    end

    # The congregation's funds kept at Betel, apart from the bank account.
    def betel_statement
      statement(kind: 'betel_statement')
    end

    def bill
      amount = labeled_total || repeated_total
      Result.new(kind: 'bill', amount_cents: money(amount), document_date: bill_date(amount),
                 description: issuer)
    end

    # After a "total" label, the first of the next three lines with a non-zero value; the
    # last value on that line, since columned layouts put the total in the last column.
    def labeled_total
      @text.to_enum(:scan, BILL_TOTAL).lazy.filter_map do
        Regexp.last_match.post_match.lines.first(3).lazy.filter_map do |line|
          last_value(line)
        end.first
      end.first
    end

    def last_value(line)
      line.scan(MONEY).reverse.find { |value| money(value).to_i.positive? }
    end

    # ponytail: fallback = largest value printed more than once (totals repeat on bills);
    # add per-issuer rules if confirmations show it guessing wrong often.
    def repeated_total
      values = @text.scan(BR_MONEY).reject { |value| value == '0,00' }
      repeated = values.tally.select { |_, count| count > 1 }.keys
      (repeated.presence || values).max_by { |value| money(value) }
    end

    # Due date (last date on the first dated line after "venc"), else a date printed
    # next to the amount, else the first date.
    def bill_date(amount)
      date(due_date || (amount && line_with(amount)&.[](DATE)) || @text[DATE])
    end

    def due_date
      lines = @text.lines
      lines.each_index.lazy.filter_map do |index|
        unless lines[index].match?(/\bvenc/i)
          next
        end

        lines[index, 3].find { |line| line.match?(DATE) }&.scan(DATE)&.last&.join('/')
      end.first
    end

    def line_with(amount)
      @text.lines.find { |line| line.include?(amount) && line.match?(DATE) }
    end

    def issuer
      name = @text[/RECEBEMOS DE\s+(\S+)/i, 1] || @text[/^\s*(\S+).*\b(?:S\.?A\.?|LTDA)\s*$/i, 1]
      name && pretty(name)
    end

    def payee
      name = @text[/(?:recebedor|Favorecido|Para)\b.*?Nome:\s*([^\n]+)/im, 1]
      name&.split&.first(2)&.map { |word| pretty(word) }&.join(' ')
    end

    def pretty(word)
      word.length <= 3 ? word : word.capitalize
    end

    def money(value)
      unless value
        return nil
      end
      # next prints "1,639.00" (US format); others print "1.639,00"
      if value.match?(/\.\d{2}\z/)
        return Money.parse(text: value.delete(',').tr('.', ','))
      end

      Money.parse(text: value)
    end

    def first_period
      period(@text.match(MONTH_YEAR))
    end

    def last_period
      period(@text.to_enum(:scan, MONTH_YEAR).map { Regexp.last_match }.last)
    end

    def period(match)
      unless match
        return nil
      end

      "#{match[2]}-#{(MONTHS.index(match[1].downcase) + 1).to_s.rjust(2, '0')}"
    end

    def long_date(text)
      match = text&.match(LONG_DATE)
      match && Date.new(match[3].to_i, MONTHS.index(match[2].downcase) + 1, match[1].to_i)
    end

    def date(text)
      match = text&.match(DATE)
      match && Date.new(match[3].to_i, match[2].to_i, match[1].to_i)
    rescue Date::Error
      nil
    end
  end
end
