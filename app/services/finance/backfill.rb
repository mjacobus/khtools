# frozen_string_literal: true

module Finance
  # Registers the files already in the account's Drive archive (Arquivo Corrente and Arquivo
  # das contas, one folder per month) as archived documents, so duplicates sent to the bot
  # are recognized and the months show what they already have. Read-only on Drive: nothing
  # there is moved, renamed or replaced.
  class Backfill
    ARCHIVES = ['Arquivo Corrente', 'Arquivo das contas'].freeze
    MONTH = /\A\d{4}-\d{2}\z/
    Row = Struct.new(:path, :kind, :competence, :status, keyword_init: true)

    def initialize(account:, drive:)
      @account = account
      @drive = drive
    end

    # Without apply, only reports what it would register.
    def run(apply:)
      @apply = apply
      @known = @account.finance_documents.where.not(drive_file_id: nil).pluck(:drive_file_id).to_set
      @drive.children(parent_id: @account.finance_drive_root_folder_id).flat_map do |entry|
        if entry[:folder] && ARCHIVES.include?(entry[:name])
          archive(entry)
        else
          [ignored(entry[:name])]
        end
      end
    end

    private

    def archive(folder)
      @drive.children(parent_id: folder[:id]).flat_map do |entry|
        path = "#{folder[:name]}/#{entry[:name]}"
        if entry[:folder] && entry[:name].match?(MONTH)
          month(entry, path, entry[:name])
        else
          [ignored(path)]
        end
      end
    end

    # Subfolders (like an "Organizar" left behind) belong to the same month.
    def month(folder, path, competence)
      @drive.children(parent_id: folder[:id]).flat_map do |entry|
        if entry[:folder]
          month(entry, "#{path}/#{entry[:name]}", competence)
        else
          [register(entry, "#{path}/#{entry[:name]}", competence)]
        end
      end
    end

    def register(file, path, competence)
      name = Name.new(file[:name], competence:)
      status = @known.include?(file[:id]) ? 'known' : 'new'
      if status == 'new' && @apply
        create(file, name, competence)
      end
      Row.new(path:, kind: name.kind, competence:, status:)
    end

    def create(file, name, competence)
      @account.finance_documents.create!(
        state: 'archived', flags: 'backfill', kind: name.kind, competence:,
        document_date: name.date, amount_cents: name.amount_cents, original_filename: file[:name],
        mime_type: file[:mime_type], sha256: file[:sha256], drive_file_id: file[:id],
        drive_url: file[:web_view_link]
      )
    end

    def ignored(path)
      Row.new(path:, status: 'ignored')
    end

    # What a file name says, as named by hand over the years ("2025-03-05 - 300 - Recibo
    # Donativo.jpeg", "20251031 - Remessa Betel.pdf", "Fatura RGE.pdf").
    class Name
      # First match wins.
      KINDS = [
        [/auditoria|S-?25/i, 'audit_report'],
        [/carta/i, 'thank_you_letter'],
        [/S-?26(?!\d)|folha de contas/i, 's26'],
        [/S-?30(?!\d)|relat[óo]rio mensal/i, 's30'],
        [/TO-?62|registro de transfer|transa[çc](?:[ãa]o|[õo]es)/i, 'remittance_record'],
        [/extrato.*betel|betel.*extrato/i, 'betel_statement'],
        [/extrato/i, 'statement'],
        [/remessa|betel/i, 'remittance_receipt'],
        [/recibo|S-?24|donativo/i, 's24'],
        [/comprovante|pagamento|\bpag\b|\bpix\b|\bTED\b/i, 'payment_receipt'],
        [/fatura|boleto|\bbol\b|\bNF(?:e|\d|\b)|nota|conta de|vencimento/i, 'bill'],
        # Older months kept one photo per expense, named by what was paid.
        [/despesa|depesa|cupom|reembolso|dep[óo]sito|retirada|luz|[áaÁA]gua|internet|limpeza|
          corsan|taxa|iptu|manuten|transfer|tranfer/ix, 'payment_receipt']
      ].freeze
      NUMBER = /\d{1,3}(?:\.\d{3})+(?:,\d{2})?|\d+(?:,\d{2})?/
      DATES = [
        [/\A(\d{4})-(\d{2})-(\d{2})/, %i[year month day]],
        [/\A(20\d{2})(\d{2})(\d{2})\b/, %i[year month day]],
        [/\A(\d{2})(\d{2})(20\d{2})\b/, %i[day month year]],
        [/\A(\d{2})(\d{2})(\d{2})\b/, %i[short_year month day]],
        [/\A(\d{2})(\d{2})(\d{2})\b/, %i[day month short_year]],
        [/\A(\d{2})\.(\d{2})\b/, %i[day month]]
      ].freeze

      def initialize(name, competence:)
        @name = name
        @competence = competence
      end

      def kind
        KINDS.find { |pattern, _| @name.match?(pattern) }&.last || (s24? ? 's24' : 'unknown')
      end

      # nil when the name has no date or an impossible one ("2024-11-31"). Six digits are
      # either 250809 or 300126: the reading close to the folder's month wins.
      def date
        DATES.each do |pattern, parts|
          match = @name.match(pattern)
          date = match && build_date(parts.zip(match.captures.map(&:to_i)).to_h)
          if date && (parts.exclude?(:short_year) || (date.year - @competence.to_i).abs <= 1)
            return date
          end
        end
        nil
      end

      def amount_cents
        number = @name[/R\$\s?(#{NUMBER})/o, 1] || @name[/\A[\d.-]+\s-\s(#{NUMBER})\s-/o, 1]
        if number
          (BigDecimal(number.delete('.').tr(',', '.')) * 100).to_i
        end
      end

      private

      # Some months named the meeting receipts only "2024-11-06 - 385.jpg".
      def s24?
        @name.match?(/\A[\d-]+ - #{NUMBER}\.\w+\z/o) && (date&.wednesday? || date&.saturday?)
      end

      def build_date(values)
        year = values[:year] || (values[:short_year] && (2000 + values[:short_year])) ||
          @competence.to_i
        Date.new(year, values[:month], values[:day])
      rescue Date::Error
        nil
      end
    end
  end
end
