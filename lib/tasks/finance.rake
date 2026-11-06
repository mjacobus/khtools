# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength -- rake namespaces are long blocks by nature
namespace :finance do
  namespace :telegram do
    finance_account = lambda do |args|
      id = args.fetch(:account_id) { abort 'usage: rake "finance:telegram:<task>[ACCOUNT_ID]"' }
      Db::Account.find(id)
    end

    desc 'Development: receive finance bot updates by long polling (removes the webhook)'
    task :poll, [:account_id] => :environment do |_task, args|
      account = finance_account.call(args)
      telegram = Telegram::Client.new(token: account.finance_telegram_bot_token)
      intake = Finance::Intake.new(account:, telegram:)
      ActiveJob::Base.queue_adapter = :inline
      telegram.delete_webhook
      puts 'Polling Telegram (Ctrl+C to stop)…'
      offset = nil
      loop do
        telegram.get_updates(offset:).each do |update|
          offset = update['update_id'] + 1
          puts "update #{update['update_id']}: #{(update.keys - ['update_id']).join(', ')}"
          begin
            intake.handle(update:)
          rescue StandardError => exception
            puts "  error: #{exception.class}: #{exception.message}"
          end
        end
      end
    end

    desc 'Point the finance bot webhook at BASE_URL (generates the secret if missing)'
    task :set_webhook, %i[account_id base_url] => :environment do |_task, args|
      account = finance_account.call(args)
      base_url = args.fetch(:base_url) do
        abort 'usage: rake "finance:telegram:set_webhook[ACCOUNT_ID,BASE_URL]"'
      end
      if account.finance_telegram_webhook_secret.blank?
        account.update!(finance_telegram_webhook_secret: SecureRandom.hex(32))
      end
      url = "#{base_url.chomp('/')}/finance/telegram/#{account.id}"
      Telegram::Client.new(token: account.finance_telegram_bot_token)
        .set_webhook(url:, secret: account.finance_telegram_webhook_secret)
      puts "Webhook set to #{url}"
    end

    desc 'Print chat and sender ids of the next updates (to configure group and confirmers)'
    task :whoami, [:account_id] => :environment do |_task, args|
      account = finance_account.call(args)
      telegram = Telegram::Client.new(token: account.finance_telegram_bot_token)
      telegram.delete_webhook
      puts 'Send a message in the group (Ctrl+C to stop)…'
      offset = nil
      loop do
        telegram.get_updates(offset:).each do |update|
          offset = update['update_id'] + 1
          message = update['message'] || update.dig('callback_query', 'message')
          from = (update['message'] || update['callback_query'])&.dig('from')
          puts "chat #{message&.dig('chat', 'id')} (#{message&.dig('chat', 'title')}) · " \
               "from #{from&.dig('id')} (#{from&.dig('first_name')})"
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
