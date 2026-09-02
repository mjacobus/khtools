# frozen_string_literal: true

module Reports
  # The S-13 grid itself, shared by the web and the printable versions.
  # Each territory takes two rows: the assignees on top, their dates below.
  class TerritoryAssignmentsTableComponent < ApplicationComponent
    has :report, public: true

    delegate :rows, :empty?, to: :report

    def column_indexes
      0...report.columns_count
    end

    def assignee_name(assignment)
      assignment&.assignee&.name
    end

    def date(value)
      if value
        l(value.to_date)
      end
    end

    def territory_cell(territory)
      if linked?
        return link_to(territory.name, urls.territory_path(territory))
      end

      territory.name
    end

    def label(key)
      t("app.reports.territory_assignments.#{key}")
    end

    private

    def linked?
      get(:linked) || false
    end
  end
end
