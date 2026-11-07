# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength -- rake namespaces are long blocks by nature
namespace :finance do
  namespace :telegram do
    $stdout.sync = true # these tasks print live while looping, often into a log file

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

  desc 'Remind each finance group of bills due in the next days or overdue (daily, from cron)'
  task remind_bills: :environment do
    Db::Account.find_each do |account|
      if account.finance_enabled?
        telegram = Telegram::Client.new(token: account.finance_telegram_bot_token)
        Finance::BillReminders.new(account:, telegram:).remind
      end
    rescue StandardError => exception
      ErrorHandler.new.notify_error(exception) # one account failing must not skip the others
    end
  end

  desc 'Bring in names, months and deletions changed directly in Drive (daily, from cron)'
  task sync_drive: :environment do
    Db::Account.find_each do |account|
      if account.finance_enabled? && account.finance_google_refresh_token.present?
        drive = GoogleDrive::Client.new(
          refresh_token: account.finance_google_refresh_token,
          client_id: Rails.application.credentials.dig(:oauth, :google, :key),
          client_secret: Rails.application.credentials.dig(:oauth, :google, :secret)
        )
        Finance::DriveSync.new(account:, drive:).sync
      end
    rescue StandardError => exception
      ErrorHandler.new.notify_error(exception) # one account failing must not skip the others
    end
  end

  desc 'Everything the finance bot does once a day'
  task daily: %i[sync_drive remind_bills]

  desc 'Register the files already in Drive (report only; [ACCOUNT_ID,apply] writes)'
  task :backfill, %i[account_id apply] => :environment do |_task, args|
    id = args.fetch(:account_id) { abort 'usage: rake "finance:backfill[ACCOUNT_ID(,apply)]"' }
    account = Db::Account.find(id)
    drive = GoogleDrive::Client.new(
      refresh_token: account.finance_google_refresh_token,
      client_id: Rails.application.credentials.dig(:oauth, :google, :key),
      client_secret: Rails.application.credentials.dig(:oauth, :google, :secret)
    )
    apply = args[:apply] == 'apply'
    report = Finance::Backfill.new(account:, drive:).run(apply:)
    report.each { |row| puts [row.status, row.kind, row.competence, row.path].compact.join("\t") }
    puts
    puts report.map(&:status).tally.map { |status, count| "#{status}: #{count}" }.join(' · ')
    puts report.reject { |row| row.status == 'ignored' }.map(&:kind).tally.sort
      .map { |kind, count| "#{kind}: #{count}" }.join(' · ')
    puts apply ? 'Registrado.' : "Nada foi gravado. Para registrar: finance:backfill[#{id},apply]"
  end
end
# rubocop:enable Metrics/BlockLength
