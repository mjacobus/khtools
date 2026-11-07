# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::DailyJob do
  let(:sync) { instance_double(Finance::DriveSync, sync: nil) }
  let(:reminders) { instance_double(Finance::BillReminders, remind: nil) }

  def account(enabled: true)
    factories.accounts.create.tap do |account|
      if enabled
        account.update!(finance_telegram_bot_token: 'token', finance_telegram_chat_id: '-100',
                        finance_drive_root_folder_id: 'ROOT', finance_google_refresh_token: 'r')
      end
    end
  end

  before do
    allow(Finance::DriveSync).to receive(:new).and_return(sync)
    allow(Finance::BillReminders).to receive(:new).and_return(reminders)
  end

  it 'syncs Drive and reminds the bills of each account with the bot on' do
    account
    account(enabled: false)

    described_class.perform_now

    expect(sync).to have_received(:sync).once
    expect(reminders).to have_received(:remind).once
  end

  it 'goes on with the other accounts when one fails' do
    2.times { account }
    failures = ['Drive down']
    allow(sync).to receive(:sync) { failures.shift&.then { |message| raise message } }
    allow(ErrorHandler).to receive(:new).and_return(instance_double(ErrorHandler,
                                                                    notify_error: nil))

    described_class.perform_now

    expect(reminders).to have_received(:remind).once
  end
end
