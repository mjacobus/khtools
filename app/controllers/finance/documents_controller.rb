# frozen_string_literal: true

module Finance
  # The archived documents of one month, grouped by type.
  class DocumentsController < ApplicationController
    MONTH = /\A\d{4}-\d{2}\z/

    def index
      months = documents.where.not(competence: nil).distinct.pluck(:competence)
      @month = requested_month || months.max
      @months = (months | [@month]).compact.sort.reverse
      @groups = groups
    end

    private

    # Any month can be opened, also one with nothing archived yet.
    def requested_month
      params[:month].to_s[MONTH]
    end

    def documents
      current_account.finance_documents.where.not(state: 'discarded')
    end

    def groups
      documents.where(competence: @month).order(:document_date, :id).group_by(&:kind)
        .sort_by { |kind, _| Db::FinanceDocument::KINDS.index(kind) }
    end
  end
end
