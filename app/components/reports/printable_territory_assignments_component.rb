# frozen_string_literal: true

module Reports
  # Printable (PDF) version of the S-13 report.
  class PrintableTerritoryAssignmentsComponent < ApplicationComponent
    has :report, public: true

    def table
      TerritoryAssignmentsTableComponent.new(report:)
    end

    # Upcased in Ruby: wkhtmltopdf's text-transform strips accents.
    def title
      label('title').upcase
    end

    def service_year_label
      "#{label('service_year')}: #{report.service_year.label}"
    end

    def label(key)
      t("app.reports.territory_assignments.#{key}")
    end
  end
end
