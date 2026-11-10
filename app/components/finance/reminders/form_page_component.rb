# frozen_string_literal: true

class Finance::Reminders::FormPageComponent < PageComponent
  attr_reader :reminder

  def initialize(reminder)
    @reminder = reminder
    setup_breadcrumb
  end

  def target_url
    if reminder.id
      return urls.finance_reminder_path(reminder)
    end

    urls.finance_reminders_path
  end

  # The people the bot saw in the group.
  def people
    reminder.account.finance_telegram_members.includes(:publisher)
      .map { |member| [member.display_name, member.id] }.sort
  end

  private

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.finance_reminders'), urls.finance_reminders_path)
    breadcrumb.add_item(reminder.id ? reminder.title : t('app.links.new'))
  end
end
