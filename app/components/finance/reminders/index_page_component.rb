# frozen_string_literal: true

class Finance::Reminders::IndexPageComponent < PageComponent
  attr_reader :reminders

  def initialize(reminders)
    @reminders = reminders
    setup_breadcrumb
  end

  def new_link
    link_to(t('app.links.new'), urls.new_finance_reminder_path)
  end

  def edit_link(reminder)
    link_to(t('app.links.edit'), urls.edit_finance_reminder_path(reminder))
  end

  def done_link(reminder)
    link_to('Feito', urls.done_finance_reminder_path(reminder), data: { method: :post })
  end

  def destroy_link(reminder)
    link_to(
      t('app.links.delete'), urls.finance_reminder_path(reminder),
      data: { method: :delete, confirm: t('app.messages.confirm_delete_x', record: reminder.title) }
    )
  end

  def pending?(reminder)
    reminder.pending?(Date.current)
  end

  private

  def setup_breadcrumb
    breadcrumb.add_item(t('app.links.finance_reminders'))
  end
end
