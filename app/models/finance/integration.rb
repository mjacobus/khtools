# frozen_string_literal: true

module Finance
  # The finance bot settings of an account, as edited on the integrations pages.
  class Integration # rubocop:disable Metrics/ClassLength
    include ActiveModel::Model

    # Write-only: a blank field keeps what is saved.
    SECRETS = { telegram_bot_token: :finance_telegram_bot_token, ai_api_key: :ai_api_key,
                statement_password: :finance_statement_password }.freeze

    # Per person in the group, by Telegram id: param => column of the member.
    MEMBER_FIELDS = { member_publisher_ids: :publisher_id, member_roles: :role }.freeze

    attr_reader :account, :telegram_chat_id, :drive_root_folder_id, :confirmer_telegram_ids

    CHAT_ID_MESSAGE = ->(*) { I18n.t('app.messages.finance_chat_id') }

    validates :telegram_chat_id, allow_blank: true,
                                 format: { with: /\A-?\d+\z/, message: CHAT_ID_MESSAGE }
    validate :resolution_money

    def self.model_name
      ActiveModel::Name.new(self, nil, 'Integration')
    end

    def initialize(account:)
      super()
      @account = account
      @telegram_chat_id = account.finance_telegram_chat_id
      @drive_root_folder_id = account.finance_drive_root_folder_id
      @confirmer_telegram_ids = account.finance_confirmer_telegram_ids.to_s.split(',')
      @members = MEMBER_FIELDS.to_h do |param, column|
        saved = account.finance_telegram_members.where.not(column => nil)
        [param, saved.to_h { |member| [member.telegram_id.to_s, member[column]] }]
      end
    end

    def member_publisher_ids = @members[:member_publisher_ids]

    # As typed: "800,00".
    def resolution
      @resolution ||= account.finance_resolution_cents&.then { |cents| Money.format(cents:)[3..] }
    end

    def member_roles = @members[:member_roles]

    # Only the fields sent are touched: each section's page sends its own.
    def update(params)
      assign(params)
      if valid?
        save(params)
        true
      end
    rescue ActiveRecord::RecordInvalid => exception
      errors.add(:base, exception.record.errors.full_messages.to_sentence)
      false
    end

    def secret_set?(name)
      account.public_send(SECRETS.fetch(name)).present?
    end

    def drive_connected?
      account.finance_google_refresh_token.present?
    end

    # People seen in the group, plus confirmers saved before anyone was seen.
    def people
      members = account.finance_telegram_members.order(:name).pluck(:telegram_id, :name)
        .map { |id, name| [id.to_s, name] }
      unknown = confirmer_telegram_ids - members.map(&:first)
      members + unknown.map { |id| [id, nil] }
    end

    def publishers
      account.publishers.pluck(:name, :id)
    end

    private

    def assign(params)
      assign_people(params)
      if params.key?(:telegram_chat_id)
        @telegram_chat_id = params[:telegram_chat_id].to_s.strip.delete_suffix('.')
      end
      if params.key?(:resolution)
        @resolution = params[:resolution].to_s.strip
      end
      if params.key?(:drive_root_folder_id)
        @drive_root_folder_id = folder_id(params[:drive_root_folder_id].to_s.strip)
      end
    end

    def assign_people(params)
      if params.key?(:confirmer_telegram_ids)
        @confirmer_telegram_ids = Array(params[:confirmer_telegram_ids]).compact_blank
      end
      MEMBER_FIELDS.each_key do |param|
        if params.key?(param)
          @members[param] = params[param].to_h.transform_values(&:presence)
        end
      end
    end

    def save(params)
      account.assign_attributes(finance_telegram_chat_id: telegram_chat_id,
                                finance_drive_root_folder_id: drive_root_folder_id,
                                finance_confirmer_telegram_ids: confirmer_telegram_ids.join(','),
                                finance_resolution_cents: Money.parse(text: resolution))
      assign_secrets(params)
      account.transaction do
        account.save!
        save_members(params)
      end
    end

    def assign_secrets(params)
      SECRETS.each do |field, attribute|
        if params[field].present?
          account.public_send(:"#{attribute}=", params[field].strip)
        end
      end
    end

    # A person can be set up before the bot has seen them (a confirmer saved by id).
    def save_members(params)
      MEMBER_FIELDS.slice(*params.keys.map(&:to_sym)).each do |param, column|
        @members[param].each do |telegram_id, value|
          account.finance_telegram_members.find_or_initialize_by(telegram_id:)
            .update!(column => value)
        end
      end
    end

    def resolution_money
      if resolution.present? && !Money.parse(text: resolution)
        errors.add(:resolution, I18n.t('app.messages.finance_resolution'))
      end
    end

    # Accepts the folder's Drive link as well as its id.
    def folder_id(value)
      value[%r{/folders/([\w-]+)}, 1] || value
    end
  end
end
