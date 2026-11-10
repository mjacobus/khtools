# frozen_string_literal: true

module Finance
  # The monthly reminders on the Lembretes tab (actions of DocumentsController, so the same
  # access covers them).
  module RecurringReminderActions
    def create_reminder
      reminder = current_account.finance_reminders
        .new(params.require(:reminder).permit(:title, :day))
      if reminder.save
        redirect_to finance_documents_path(view: 'reminders')
      else
        redirect_to finance_documents_path(view: 'reminders'),
                    flash: { error: 'Informe o lembrete e um dia de 1 a 31.' }
      end
    end

    def reminder_done
      recurring_reminder.done!(Date.current)
      redirect_to finance_documents_path(view: 'reminders')
    end

    def destroy_reminder
      recurring_reminder.destroy!
      redirect_to finance_documents_path(view: 'reminders')
    end

    private

    def recurring_reminder
      current_account.finance_reminders.find(params[:reminder_id])
    end
  end
end
