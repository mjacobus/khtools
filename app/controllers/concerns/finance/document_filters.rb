# frozen_string_literal: true

module Finance
  # The month's documents by date ("Por período"), or every month's, newest first ("Todos"),
  # filtered by type and by a search on the file name; or the archive reminders ("Lembretes").
  module DocumentFilters
    extend ActiveSupport::Concern

    PER_PAGE = 50
    DATED = "COALESCE(document_date, date(competence || '-01', '+1 month', '-1 day'))"

    included { helper_method :all_documents_view?, :reminders_view?, :archive_reminders }

    private

    def all_documents_view?
      params[:view] == 'all'
    end

    def reminders_view?
      params[:view] == 'reminders'
    end

    def archive_reminders
      @archive_reminders ||= ArchiveReminders.new(account: current_account)
    end

    # @listed is every match (the totals); @documents is what the page shows. Only "Todos" is
    # paged: a month has a few dozen documents.
    def list_documents
      scope = all_documents_view? ? documents : documents.where(competence: @month)
      @kinds = scope.distinct.pluck(:kind).sort_by { |kind| Db::FinanceDocument::KINDS.index(kind) }
      @listed = search(of_kind(scope).order(document_order).to_a)
      @documents = paged(@listed)
    end

    # ponytail: pages in Ruby because the search runs on the built name; fine for thousands.
    def paged(list)
      if all_documents_view?
        Kaminari.paginate_array(list).page(params[:page]).per(PER_PAGE)
      else
        list
      end
    end

    # Newest first in "Todos"; undated documents (statements, S-26...) count as the last day of
    # their month. The month in date order. Either way, what has no date at all goes last.
    def document_order
      if all_documents_view?
        Arel.sql("#{DATED} IS NULL, #{DATED} DESC, id DESC")
      else
        Arel.sql('document_date IS NULL, document_date, id')
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
