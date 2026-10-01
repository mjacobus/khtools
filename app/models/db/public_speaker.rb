# frozen_string_literal: true

class Db::PublicSpeaker < ApplicationRecord
  belongs_to :account, class_name: 'Db::Account'
  belongs_to :congregation, optional: true

  scope :with_dependencies, -> { includes(:congregation) }

  validates :name, presence: true
  validate :congregation_belongs_to_account

  def congregation_name
    congregation&.name
  end

  private

  def congregation_belongs_to_account
    if congregation && congregation.account_id != account_id
      errors.add(:congregation, :invalid)
    end
  end
end
