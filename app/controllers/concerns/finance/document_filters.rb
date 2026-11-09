# frozen_string_literal: true

module Finance
  # The month's documents by date ("Por período"), or every month's, newest first ("Todos"),
  # filtered by type and by a search on the file name.
  module DocumentFilters
    extend ActiveSupport::Concern

    included { helper_method :all_documents_view? }

    private

    def all_documents_view?
      params[:view] == 'all'
    end

    # ponytail: no pagination; a congregation files a few hundred documents a year.
    def list_documents
      scope = all_documents_view? ? documents : documents.where(competence: @month)
      @kinds = scope.distinct.pluck(:kind).sort_by { |kind| Db::FinanceDocument::KINDS.index(kind) }
      @documents = search(of_kind(scope).order(Arel.sql('document_date IS NULL'), document_order)
                            .to_a)
    end

    def document_order
      if all_documents_view?
        { document_date: :desc, id: :desc }
      else
        { document_date: :asc, id: :asc }
      end
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
