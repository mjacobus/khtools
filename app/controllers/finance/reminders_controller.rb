# frozen_string_literal: true

module Finance
  # The monthly reminders (paying the internet bill on the 10th...): set up here, sent by the bot
  # every morning while pending, marked done here, on the Lembretes tab or on Telegram.
  class RemindersController < ApplicationController
    def index
      @reminders = reminders.order(:day, :id)
      @members = current_account.finance_telegram_members.includes(:publisher)
        .sort_by(&:display_name)
    end

    def create
      save(reminders.new)
    end

    def update
      save(reminder)
    end

    def destroy
      reminder.destroy!
      redirect_to finance_reminders_path
    end

    def done
      reminder.done!(Date.current)
      redirect_back_or_to finance_reminders_path
    end

    private

    def save(reminder)
      if reminder.update(reminder_params)
        redirect_to finance_reminders_path
      else
        redirect_to finance_reminders_path,
                    flash: { error: 'Informe o lembrete e um dia de 1 a 31.' }
      end
    end

    def reminders
      current_account.finance_reminders
    end

    def reminder
      reminders.find(params[:id])
    end

    # Only people of this congregation's group can be responsible.
    def reminder_params
      permitted = params.require(:reminder).permit(:title, :day, :finance_telegram_member_id)
      member_id = permitted[:finance_telegram_member_id].presence
      member = member_id && current_account.finance_telegram_members.find(member_id)
      permitted.merge(finance_telegram_member_id: member&.id)
    end
  end
end
