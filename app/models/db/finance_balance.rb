# frozen_string_literal: true

# The bank account balance a month starts with, as the previous month's S-26 closed it (not the
# statement's: S-24s in transit and the remittance make them differ).
class Db::FinanceBalance < ApplicationRecord
  belongs_to :account, class_name: 'Db::Account'

  validates :competence, format: { with: /\A\d{4}-(0[1-9]|1[0-2])\z/ },
                         uniqueness: { scope: :account_id }
  validates :opening_cents, presence: true
end
