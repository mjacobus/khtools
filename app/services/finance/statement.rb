# frozen_string_literal: true

module Finance
  # The lines of a bank statement (next/Bradesco, `pdftotext -layout`). Each entry is a
  # "3212-PIX RECEBIDO" history row, an amounts row (date only on the day's first entry) and,
  # for Pix, a "REM:"/"DES:" row with who sent or got it. Overlapping statements repeat the
  # same Docto. number, kept once.
  class Statement
    Line = Struct.new(:date, :doc, :history, :cents, :balance_cents, :who, keyword_init: true)

    DATE = %r{\A\s*(\d\d/\d\d/\d{4})}
    HISTORY = /\A\s+\d{4}-(.+?)\s*\z/
    AMOUNTS = /\s(\d{4,})\s+(R\$ -?[\d.,]+)\s+(?:R\$ -?[\d.,]+\s+)?R\$ (-?[\d.,]+)\s*\z/
    WHO = %r{\A\s+(?:REM|DES|DEST): (.+?)(?:\s+\d\d/\d\d)?\s*\z}
    HOLDER = /^\s*Nome:\s+(.+?)\s*$/

    def self.parse(text) = new.parse(text)
    def self.holder(text) = text[HOLDER, 1]

    def parse(text)
      @lines = []
      text.each_line { |row| read(row) }
      @lines.uniq(&:doc)
    end

    private

    def read(row)
      if row[DATE, 1]
        @date = Date.strptime(row[DATE, 1], '%d/%m/%Y')
      end
      history(row) || amounts(row) || who(row)
    end

    def history(row)
      @history = row[HISTORY, 1] || @history
      row.match?(HISTORY)
    end

    def amounts(row)
      match = @history && row.match(AMOUNTS)
      if match
        @lines << Line.new(date: @date, doc: match[1], history: @history, cents: cents(match[2]),
                           balance_cents: cents(match[3]))
        @history = nil
      end
      match
    end

    def who(row)
      name = row[WHO, 1]
      if name && @lines.any?
        @lines.last.who = name
      end
    end

    def cents(text)
      (text.delete('R$. ').tr(',', '.').to_d * 100).to_i
    end
  end
end
