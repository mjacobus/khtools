# frozen_string_literal: true

module Reports
  class TerritoryAssignmentsController < ApplicationController
    def index
      respond_to do |format|
        format.html { render(TerritoryAssignmentsPageComponent.new(report:)) }
        format.pdf { render_pdf }
        format.xlsx { render_spreadsheet }
      end
    end

    private

    def render_pdf
      @component = PrintableTerritoryAssignmentsComponent.new(report:)

      export_pdf(report.filename('pdf'), orientation: 'Landscape')
    end

    def render_spreadsheet
      send_data(spreadsheet.to_stream.read, filename: spreadsheet.filename)
    end

    def report
      @report ||= TerritoryAssignmentReport.new(
        account: current_account,
        service_year: ServiceYear.from_param(params[:service_year]),
        type: TerritoryAssignmentReport.type_for(params[:type])
      )
    end

    def spreadsheet
      @spreadsheet ||= TerritoryAssignmentSpreadsheet.new(report)
    end
  end
end
