# frozen_string_literal: true

module Finance
  # The month's documents by date, filtered by type and by a search on the file name.
  module DocumentFilters
    private

    def list_month
      month_documents = documents.where(competence: @month)
      @kinds = month_documents.distinct.pluck(:kind)
        .sort_by { |kind| Db::FinanceDocument::KINDS.index(kind) }
      @documents = search(of_kind(month_documents).order(Arel.sql('document_date IS NULL'),
                                                         :document_date, :id).to_a)
    end

    def of_kind(scope)
      if params[:kind].present?
        scope.where(kind: params[:kind])
      else
        scope
      end
    end

    # In Ruby: the shown name is built (Naming), not stored.
    def search(list)
      query = params[:q].to_s.strip.downcase
      if query.present?
        list.select { |document| document.drive_name.to_s.downcase.include?(query) }
      else
        list
      end
    end
  end
end
