# frozen_string_literal: true

module Reports
  # Web version of the S-13 report: filters, download links and the grid.
  class TerritoryAssignmentsPageComponent < PageComponent
    has :report, public: true

    delegate :service_year, to: :report

    def table
      TerritoryAssignmentsTableComponent.new(report:, linked: true)
    end

    def title
      label('title')
    end

    def service_year_options
      available_service_years.map { |year| [year.label, year.to_param] }
    end

    def type_options
      all = [[label('all_types'), TerritoryAssignmentReport::ALL_TYPES]]

      all + TerritoryAssignmentReport::TYPES.map do |key, klass|
        [klass.model_name.human, key]
      end
    end

    def pdf_url
      urls.reports_territory_assignments_path(export_params.merge(format: :pdf))
    end

    def xlsx_url
      urls.reports_territory_assignments_path(export_params.merge(format: :xlsx))
    end

    def label(key)
      t("app.reports.territory_assignments.#{key}")
    end

    private

    def export_params
      { service_year: service_year.to_param, type: report.type_key }
    end

    def available_service_years
      @available_service_years ||= get(:service_years) ||
        TerritoryAssignmentReport.available_service_years(current_account)
    end

    def setup_breadcrumb
      breadcrumb.add_item(t('app.links.reports'))
      breadcrumb.add_item(t('app.links.territory_assignment_report'))
    end
  end
end
