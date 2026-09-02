# frozen_string_literal: true

module Reports
  # Renders the S-13 report as an xlsx workbook, mirroring the printed form:
  # each territory takes two rows, assignees on top and their dates below.
  class TerritoryAssignmentSpreadsheet
    delegate :to_stream, to: :to_package

    def initialize(report)
      @report = report
    end

    def to_package
      package = Axlsx::Package.new
      @styles = build_styles(package.workbook)

      package.workbook.add_worksheet(name: sheet_name) do |sheet|
        grid = PairedRowSheet.new(sheet, pairs: report.columns_count)

        add_title(grid)
        add_header(grid)
        report.rows.each { |row| add_territory(grid, row) }
        grid.column_widths([8, 16], 14)
      end

      package
    end

    def filename
      report.filename('xlsx')
    end

    private

    attr_reader :report
    attr_reader :styles

    def add_title(grid)
      grid.add_merged_row(label('title'), styles[:title])
      grid.add_merged_row("#{label('service_year')}: #{report.service_year.label}",
                          styles[:subtitle])
    end

    def add_header(grid)
      grid.add_pair(
        [label('territory_number'), "#{label('last_completed_at')}*"],
        columns.flat_map { [label('assigned_to'), nil] },
        columns.flat_map { [label('assigned_at'), label('returned_at')] },
        style: styles[:header]
      )
    end

    def add_territory(grid, row)
      grid.add_pair(
        [row.territory.name, date(row.last_completed_at)],
        assignee_cells(row),
        date_cells(row),
        style: styles[:cell]
      )
    end

    def assignee_cells(row)
      assignments_of(row).flat_map { |assignment| [assignee_name(assignment), nil] }
    end

    def date_cells(row)
      assignments_of(row).flat_map { |assignment| assignment_dates(assignment) }
    end

    # Padded to the report width, so short rows still fill every column.
    def assignments_of(row)
      Array.new(report.columns_count) { |index| row.assignments[index] }
    end

    def columns
      Array.new(report.columns_count)
    end

    def assignee_name(assignment)
      assignment&.assignee&.name
    end

    def assignment_dates(assignment)
      [date(assignment&.assigned_at), date(assignment&.returned_at)]
    end

    def date(value)
      if value
        I18n.l(value.to_date)
      end
    end

    def sheet_name
      report.service_year.label.tr('/', '-')
    end

    def label(key)
      I18n.t("app.reports.territory_assignments.#{key}")
    end

    def build_styles(workbook)
      border = { style: :thin, color: 'FF000000' }
      centered = { horizontal: :center, vertical: :center, wrap_text: true }

      {
        title: workbook.styles.add_style(b: true, sz: 14, alignment: centered),
        subtitle: workbook.styles.add_style(b: true),
        header: workbook.styles.add_style(b: true, alignment: centered, border:),
        cell: workbook.styles.add_style(alignment: centered, border:)
      }
    end
  end
end
