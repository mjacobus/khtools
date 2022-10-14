# frozen_string_literal: true

module AccountAwareCrudController
  extend ActiveSupport::Concern

  private

  def before_save(record)
    record.account_id = current_account.id
  end
end
