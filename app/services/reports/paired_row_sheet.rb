# frozen_string_literal: true

module Reports
  # Writes the S-13 grid into an Axlsx worksheet. The grid has two fixed
  # columns followed by a number of column pairs, and every entry takes two
  # rows: the top one carries cells merged over each pair, the bottom one
  # carries the pair of columns itself.
  class PairedRowSheet
    FIXED_COLUMNS = 2

    def initialize(sheet, pairs:)
      @sheet = sheet
      @pairs = pairs
    end

    def total_columns
      FIXED_COLUMNS + (pairs * 2)
    end

    # A single value merged over the whole width.
    def add_merged_row(text, style)
      row = sheet.add_row(padded([text]), style:)

      merge(row.cells.first, row.cells.last)
    end

    def add_pair(fixed, top, bottom, style:)
      first = sheet.add_row(fixed + top, style:, types: text_types)
      second = sheet.add_row(blank_fixed + bottom, style:, types: text_types)

      merge_fixed_columns(first, second)
      merge_pairs(first)
    end

    def column_widths(fixed, pair)
      sheet.column_widths(*fixed, *Array.new(pairs * 2, pair))
    end

    private

    attr_reader :sheet
    attr_reader :pairs

    # "Terr. n.º" and "Última data concluída" span both rows of an entry.
    def merge_fixed_columns(first, second)
      FIXED_COLUMNS.times { |index| merge(first.cells[index], second.cells[index]) }
    end

    def merge_pairs(row)
      pairs.times do |index|
        merge(row.cells[FIXED_COLUMNS + (index * 2)], row.cells[FIXED_COLUMNS + (index * 2) + 1])
      end
    end

    def merge(from, to)
      sheet.merge_cells([from, to])
    end

    def padded(values)
      values + Array.new(total_columns - values.size)
    end

    def blank_fixed
      Array.new(FIXED_COLUMNS)
    end

    # Territory numbers and dates are labels, not quantities: "007" must stay "007".
    def text_types
      Array.new(total_columns, :string)
    end
  end
end
