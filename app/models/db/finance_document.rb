# frozen_string_literal: true

class Db::FinanceDocument < ApplicationRecord
  STATES = %w[received suggested confirmed archived discarded].freeze
  KINDS = %w[
    s24 payment_receipt bill statement s26 s30 remittance_record remittance_receipt
    thank_you_letter audit_report unknown
  ].freeze

  belongs_to :account, class_name: 'Db::Account'

  validates :telegram_chat_id, :telegram_message_id, :telegram_file_id, presence: true
  validates :state, inclusion: { in: STATES }
  validates :kind, inclusion: { in: KINDS }
  validates :telegram_message_id, uniqueness: { scope: %i[account_id telegram_chat_id] }

  scope :stuck, -> { where(state: %w[received confirmed]).where(updated_at: ...10.minutes.ago) }

  def flag_list
    flags.to_s.split(',')
  end

  def flagged?(flag)
    flag_list.include?(flag.to_s)
  end

  def add_flag(flag)
    self.flags = (flag_list | [flag.to_s]).join(',')
  end
end
