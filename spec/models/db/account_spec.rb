# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::Account, type: :model do
  subject(:account) { factories.accounts.build }

  it { is_expected.to validate_uniqueness_of(:congregation_name).case_insensitive }
  it { is_expected.to have_many(:users) }
  it { is_expected.to have_many(:publishers).class_name('Db::Publisher') }
  it { is_expected.to have_many(:field_service_groups).class_name('Db::FieldServiceGroup') }
  it { is_expected.to have_many(:territories).class_name('Db::Territory') }
  it { is_expected.to have_many(:preaching_campaigns).class_name('Db::PreachingCampaign') }

  it 'has encrypted cloudinary_cloud_name' do
    account.cloudinary_cloud_name = 'a-secret'

    account.save

    account.reload

    expect(account.cloudinary_cloud_name).to eq('a-secret')

    records = ActiveRecord::Base.connection.execute(account.class.all.to_sql)
    expect(records.first['secrets'].to_s).not_to include('a-secret')
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
end
