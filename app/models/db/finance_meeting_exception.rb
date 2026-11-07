# frozen_string_literal: true

# A meeting day without a collection (moved_to nil) or held on another day.
class Db::FinanceMeetingException < ApplicationRecord
  belongs_to :account, class_name: 'Db::Account'

  validates :date, presence: true, uniqueness: { scope: :account_id }
end
