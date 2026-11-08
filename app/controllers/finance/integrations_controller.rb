# frozen_string_literal: true

module Finance
  # The finance bot settings, one page per service: Telegram, Google Drive and OpenAI.
  class IntegrationsController < ApplicationController
    SECTIONS = %w[telegram drive ai].freeze

    before_action :find_section

    def show
      @integration = Integration.new(account: current_account)
    end

    def update
      @integration = Integration.new(account: current_account)
      if @integration.update(integration_params)
        redirect_to finance_integration_path(@section),
                    notice: t('app.messages.finance_integration_saved')
      else
        render :show, status: :unprocessable_entity
      end
    end

    # The Bot API can't list a group's members, only its administrators.
    def members
      telegram = Telegram::Client.new(token: current_account.finance_telegram_bot_token)
      admins = telegram.chat_administrators(chat_id: current_account.finance_telegram_chat_id)
      admins.each do |admin|
        Db::FinanceTelegramMember.remember(account: current_account, telegram_id: admin[:id],
                                           name: admin[:name])
      end
      redirect_to finance_integration_path(@section)
    rescue Telegram::Client::Error => exception
      redirect_to finance_integration_path(@section), flash: { error: exception.message }
    end

    private

    def find_section
      @section = params[:section]
      unless SECTIONS.include?(@section)
        render_page404(nil)
      end
    end

    def integration_params
      params.require(:integration).permit(:telegram_chat_id, :drive_root_folder_id,
                                          *Integration::SECRETS.keys, confirmer_telegram_ids: [],
                                                                      member_user_ids: {})
    end
  end
end
