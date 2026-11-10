# frozen_string_literal: true

module Finance
  # The monthly reminders (paying the internet bill on the 10th...): set up here, sent by the bot
  # every morning while pending, marked done here, on the Lembretes tab or on Telegram.
  class RemindersController < ApplicationController
    include CrudController
    include AccountAwareCrudController

    key :reminder

    scope { current_account.finance_reminders.includes(responsible: :publisher).order(:day, :id) }

    permit :title, :day, :finance_telegram_member_id

    component_class_template 'Finance::Reminders::%{type}PageComponent', use_key: false

    def done
      current_account.finance_reminders.find(params[:id]).done!(Date.current)
      redirect_back_or_to finance_reminders_path
    end

    private

    def find_scope
      current_account.finance_reminders
    end
  end
end
