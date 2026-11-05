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

  # Remittances are dated on the last day of the month they belong to (S-27b par. 27).
  def assign_competence(period: nil)
    self.competence = Finance::Competence.default_for(kind:, document_date:, period:)
    return unless competence && Finance::Competence::REMITTANCE.include?(kind)

    self.document_date = Finance::Competence.remittance_date(competence:)
  end

  # Original bytes kept only until archived. Not a persistent volume: if a deploy wipes it,
  # the file is downloaded from Telegram again.
  def local_path
    Rails.root.join('storage/finance', "#{id}#{Finance::Naming.extension(self)}")
  end

  def pdf?
    mime_type == 'application/pdf' || File.extname(original_filename.to_s).casecmp?('.pdf')
  end

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
