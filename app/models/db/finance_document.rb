# frozen_string_literal: true

class Db::FinanceDocument < ApplicationRecord # rubocop:disable Metrics/ClassLength -- states, cash, bills, naming
  STATES = %w[received suggested confirmed archived discarded failed].freeze
  KINDS = %w[
    s24 payment_receipt bill statement betel_statement s26 s30 remittance_record remittance_receipt
    thank_you_letter audit_report unknown
  ].freeze

  # Files deleted in Drive are soft deleted; Finance::DriveSync brings them back if restored.
  default_scope { where(deleted_at: nil) }

  belongs_to :account, class_name: 'Db::Account'
  # A payment receipt points to the bill it paid.
  belongs_to :bill, class_name: 'Db::FinanceDocument', optional: true
  has_many :payments, class_name: 'Db::FinanceDocument', foreign_key: :bill_id,
                      inverse_of: :bill, dependent: :nullify

  validates :telegram_chat_id, :telegram_message_id, :telegram_file_id, presence: true,
                                                                        unless: :backfilled?
  validates :state, inclusion: { in: STATES }
  validates :kind, inclusion: { in: KINDS }
  validates :competence, format: { with: /\A\d{4}-(0[1-9]|1[0-2])\z/ }, allow_nil: true
  validate :audit_report_in_last_month, if: lambda {
    kind == 'audit_report' && competence.present? &&
      (will_save_change_to_competence? || will_save_change_to_kind?)
  }
  validates :telegram_message_id, uniqueness: { scope: %i[account_id telegram_chat_id] },
                                  allow_nil: true

  # Bills without a due date (most from the backfill) are never counted as open.
  scope :open_bills, lambda {
    where(kind: 'bill', paid_on: nil).where.not(due_date: nil).where.not(state: 'discarded')
  }
  # S-24 cash nobody tapped "Recebi" for yet; see cash_owed? for the Pix.
  scope :cash_pending, lambda {
    where(kind: 's24', state: 'archived', cash_received_at: nil).where.not(cash_holder_name: nil)
  }
  scope :stuck, -> { where(state: %w[received confirmed]).where(updated_at: ...10.minutes.ago) }

  # Moves from one state to another only if nobody else did first (Telegram delivers
  # updates in parallel, so two taps can race).
  def claim(from:, **changes)
    claimed = self.class.where(id:, state: from)
      .update_all(changes.merge(updated_at: Time.current)) == 1 # rubocop:disable Rails/SkipsModelValidations
    reload if claimed
    claimed
  end

  # Remittances are dated on the last day of the month they belong to (S-27b par. 27).
  def assign_competence(period: nil)
    self.competence = Finance::Competence.default_for(kind:, document_date:, period:)
    unless competence && Finance::Competence::REMITTANCE.include?(kind)
      return
    end

    self.document_date = Finance::Competence.remittance_date(competence:)
  end

  # Original bytes kept only until archived. Not a persistent volume: if a deploy wipes it,
  # the file is downloaded from Telegram again.
  def local_path
    Rails.root.join('storage/finance', "#{id}#{Finance::Naming.extension(self)}")
  end

  def store_local_copy(bytes)
    FileUtils.mkdir_p(File.dirname(local_path))
    File.binwrite(local_path, bytes)
  end

  # Only earlier documents count, so exactly one of two simultaneous uploads wins.
  def earlier_duplicate
    account.finance_documents.where(sha256:).where(id: ...id).where.not(state: 'discarded').first
  end

  # Monthly documents have one file per month: a corrected S-26 replaces the one the bot
  # archived before (same name). Files the bot did not upload (backfill) are never replaced.
  def replaced_document
    if Finance::Competence::MONTHLY.include?(kind) && competence
      name = Finance::Naming.filename(document: self)
      archived_same_month.find { |document| Finance::Naming.filename(document:) == name }
    end
  end

  def archived_same_month
    self.class.where(account_id:, state: 'archived', kind:, competence:)
      .where.not(id:).where.not(drive_file_id: nil).order(id: :desc)
      .reject(&:backfilled?)
  end

  # The name the file has in Drive: the bot names what it uploads, the backfill keeps names
  # until someone edits the file in khtools, and a rename in Drive itself wins over both.
  # Whoever kept an S-24's cash is even once someone got it ("Recebi") or once they made the Pix
  # themselves. When someone else made the Pix, the cash is owed to them.
  def cash_owed?
    cash_holder_name.present? && cash_received_at.nil? && !pix_by_holder?
  end

  def cash_creditor
    if cash_pix_at && cash_owed?
      cash_pix_by
    end
  end

  def drive_name
    if drive_filename.present? # renamed in Drive itself (DriveSync)
      drive_filename
    elsif backfilled? && !flagged?(:renamed)
      original_filename
    else
      Finance::Naming.filename(document: self)
    end
  end

  # paid, paid_late, open, overdue, or nil when the due date is unknown.
  def payment_status(today: Date.current)
    if paid_on
      due_date && paid_on > due_date ? 'paid_late' : 'paid'
    elsif due_date
      due_date < today ? 'overdue' : 'open'
    end
  end

  # Registered from a file already in Drive, not received through Telegram.
  def backfilled?
    flagged?(:backfill)
  end

  def pdf?
    mime_type == 'application/pdf' || File.extname(original_filename.to_s).casecmp?('.pdf')
  end

  # Call after applying a correction and before saving: the pending changes are what it changed.
  def record_correction(by_telegram_id:, by_name:, text:)
    changed = changes_to_save.except('value_source', 'corrections', 'updated_at')
    entry = { 'at' => Time.current.iso8601, 'by_telegram_id' => by_telegram_id,
              'by_name' => by_name, 'text' => text, 'changes' => changed }
    self.corrections = corrections + [entry]
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

  private

  # By Telegram id; by name for older records and for a Pix marked on the web by someone not
  # linked to the group.
  def pix_by_holder?
    if cash_pix_at.nil?
      false
    elsif cash_pix_by_telegram_id && cash_holder_telegram_id
      cash_pix_by_telegram_id == cash_holder_telegram_id
    else
      cash_pix_by == cash_holder_name
    end
  end

  def audit_report_in_last_month
    message = Finance::Competence.audit_month_error(competence)
    if message
      errors.add(:competence, message)
    end
  end
end
