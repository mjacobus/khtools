# frozen_string_literal: true

module Finance
  # Meeting days without collection, or moved to another day (actions of DocumentsController,
  # so the same access covers them).
  module MeetingExceptions
    def create_meeting_exception
      exception = current_account.finance_meeting_exceptions
        .find_or_initialize_by(date: meeting_date)
      exception.update!(moved_to: params[:moved_to].presence)
      redirect_to finance_documents_path(month: Competence.month(exception.date))
    end

    def destroy_meeting_exception
      current_account.finance_meeting_exceptions.where(date: meeting_date).delete_all
      redirect_to finance_documents_path(month: Competence.month(meeting_date))
    end

    private

    def meeting_date
      Date.iso8601(params.require(:date))
    end
  end
end
