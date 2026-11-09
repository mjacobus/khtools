# frozen_string_literal: true

class Db::Account < ApplicationRecord
  encrypts :secrets

  validates :congregation_name, uniqueness: { case_sensitive: false }, presence: true

  has_many :users, dependent: :restrict_with_exception
  has_many :publishers, dependent: :restrict_with_exception, class_name: 'Db::Publisher'
  has_many :meetings, dependent: :restrict_with_exception,
                      class_name: 'Db::MeetingAttendance::Meeting'
  has_many :congregations, dependent: :restrict_with_exception, class_name: 'Db::Congregation'
  has_many :public_speakers, dependent: :restrict_with_exception, class_name: 'Db::PublicSpeaker'
  has_many :public_talks, dependent: :restrict_with_exception, class_name: 'Db::PublicTalk'
  has_many :field_service_groups, dependent: :restrict_with_exception,
                                  class_name: 'Db::FieldServiceGroup'
  has_many :territories, dependent: :restrict_with_exception,
                         class_name: 'Db::Territory'
  has_many :preaching_campaigns, dependent: :restrict_with_exception,
                                 class_name: 'Db::PreachingCampaign'
  has_many :finance_documents, dependent: :restrict_with_exception,
                               class_name: 'Db::FinanceDocument'
  has_many :finance_meeting_exceptions, dependent: :delete_all,
                                        class_name: 'Db::FinanceMeetingException'
  has_many :finance_telegram_members, dependent: :delete_all,
                                      class_name: 'Db::FinanceTelegramMember'

  FINANCE_SECRETS = %i[
    finance_telegram_bot_token finance_telegram_webhook_secret finance_telegram_chat_id
    finance_confirmer_telegram_ids finance_google_refresh_token finance_drive_root_folder_id
    finance_statement_password ai_api_key
  ].freeze

  FINANCE_SECRETS.each do |name|
    define_method(name) { read_secret(name) }
    define_method(:"#{name}=") { |value| write_secret(name, value) }
  end

  def to_s
    congregation_name
  end

  def cloudinary_cloud_name=(value)
    write_secret(:cloudinary_cloud_name, value)
  end

  def cloudinary_cloud_name
    read_secret(:cloudinary_cloud_name)
  end

  def cloudinary_api_key=(value)
    write_secret(:cloudinary_api_key, value)
  end

  def cloudinary_api_key
    read_secret(:cloudinary_api_key)
  end

  def cloudinary_api_secret=(value)
    write_secret(:cloudinary_api_secret, value)
  end

  def cloudinary_api_secret
    read_secret(:cloudinary_api_secret)
  end

  def google_api_key_for_static_maps=(value)
    write_secret(:google_api_key_for_static_maps, value)
  end

  def google_api_key_for_static_maps
    read_secret(:google_api_key_for_static_maps)
  end

  def supports_uploads?
    [cloudinary_cloud_name, cloudinary_api_key, cloudinary_api_secret].all?(&:present?)
  end

  # The accounts servant and helpers: the ones who receive the meeting cash, servant first.
  def finance_cash_receivers
    finance_telegram_members.where(role: Db::FinanceTelegramMember::CASH_RECEIVERS)
      .in_order_of(:role, Db::FinanceTelegramMember::CASH_RECEIVERS).order(:id)
  end

  def finance_confirmer?(telegram_user_id)
    finance_confirmer_telegram_ids.to_s.split(',').map(&:strip).include?(telegram_user_id.to_s)
  end

  def finance_enabled?
    [finance_telegram_bot_token, finance_telegram_chat_id,
     finance_drive_root_folder_id].all?(&:present?)
  end

  private

  def write_secret(attribute, value)
    parsed_secrets[attribute.to_s] = value
    self.secrets = parsed_secrets.to_json
  end

  def read_secret(attribute)
    parsed_secrets[attribute.to_s]
  end

  def parsed_secrets
    @parsed_secrets ||= if secrets.is_a?(String)
                          JSON.parse(secrets)
                        else
                          {}
                        end
  end
end
