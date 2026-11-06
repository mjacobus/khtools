# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::Account do
  subject(:account) { factories.accounts.build }

  it { is_expected.to validate_uniqueness_of(:congregation_name).case_insensitive }
  it { is_expected.to have_many(:users) }
  it { is_expected.to have_many(:publishers).class_name('Db::Publisher') }
  it { is_expected.to have_many(:meetings).class_name('Db::MeetingAttendance::Meeting') }
  it { is_expected.to have_many(:congregations).class_name('Db::Congregation') }
  it { is_expected.to have_many(:public_speakers).class_name('Db::PublicSpeaker') }
  it { is_expected.to have_many(:public_talks).class_name('Db::PublicTalk') }
  it { is_expected.to have_many(:field_service_groups).class_name('Db::FieldServiceGroup') }
  it { is_expected.to have_many(:territories).class_name('Db::Territory') }
  it { is_expected.to have_many(:preaching_campaigns).class_name('Db::PreachingCampaign') }
  it { is_expected.to have_many(:finance_documents).class_name('Db::FinanceDocument') }

  it 'has encrypted cloudinary_cloud_name' do
    account.cloudinary_cloud_name = 'a-secret'

    account.save

    account.reload

    expect(account.cloudinary_cloud_name).to eq('a-secret')

    records = ActiveRecord::Base.connection.execute(account.class.all.to_sql)
    expect(records.first['secrets'].to_s).not_to include('a-secret')
    expect(account.class.find(account.id).cloudinary_cloud_name).to eq('a-secret')
  end

  it 'has encrypted cloudinary_api_key' do
    expect { account.cloudinary_api_key = 'foo' }
      .to change { account.cloudinary_api_key }
      .from(nil).to('foo')
  end

  it 'has encrypted cloudinary_api_secret' do
    expect { account.cloudinary_api_secret = 'foo' }
      .to change { account.cloudinary_api_secret }
      .from(nil).to('foo')
  end

  it 'responds to supports_uploads?' do
    account.cloudinary_cloud_name = 'name'
    account.cloudinary_api_key = 'key'
    account.cloudinary_api_secret = 'secret'

    expect { account.cloudinary_cloud_name = '' }
      .to change { account.supports_uploads? }
      .from(true).to(false)
  end

  describe 'finance settings' do
    %i[
      finance_telegram_bot_token finance_telegram_webhook_secret finance_telegram_chat_id
      finance_confirmer_telegram_ids finance_google_refresh_token finance_drive_root_folder_id
      finance_statement_password ai_api_key
    ].each do |attribute|
      it "stores #{attribute} encrypted in secrets" do
        account.public_send(:"#{attribute}=", 'a-secret')
        account.save!

        expect(account.class.find(account.id).public_send(attribute)).to eq('a-secret')
        raw = ActiveRecord::Base.connection
          .select_value("SELECT secrets FROM accounts WHERE id = #{account.id}")
        expect(raw.to_s).not_to include('a-secret')
      end
    end

    it 'knows who can confirm' do
      account.finance_confirmer_telegram_ids = '7, 42'

      expect(account.finance_confirmer?('42')).to be(true)
      expect(account.finance_confirmer?(42)).to be(true)
      expect(account.finance_confirmer?('8')).to be(false)
    end

    it 'has no confirmers when unset' do
      expect(account.finance_confirmer?('42')).to be(false)
    end

    it 'is finance enabled with bot token, chat id and root folder' do
      account.finance_telegram_bot_token = 'token'
      account.finance_telegram_chat_id = '-100'

      expect { account.finance_drive_root_folder_id = 'folder' }
        .to change(account, :finance_enabled?).from(false).to(true)
    end
  end
end
