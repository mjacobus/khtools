# frozen_string_literal: true

module DevRandomModule
  def random
    order('RANDOM()').first
  end
end

ApplicationRecord.extend(DevRandomModule)

Db::Account.create!(congregation_name: 'Test Congregation')

[
  Db::MeetingAttendance::Meeting,
  Db::PreachingCampaign,
  Db::Publisher,
  Db::Territory,
  Db::FieldServiceGroup,
  Db::PhoneProvider
].map(&:delete_all)

1.upto(10) do |num|
  Db::MeetingAttendance::Meeting.create!(title: "Meeting #{num}", created_at: num.days.ago)
end

require_relative '../spec/support/test_factories'
factory = TestFactories.new

1.upto(4) do
  factory.field_service_groups.create
  factory.phone_providers.create
  factory.preaching_campaigns.create
end

1.upto(20) do
  factory.phone_list_territories.create(
    phone_provider: Db::PhoneProvider.random
  )
  factory.territories.create
  factory.apartment_building_territories.create
  factory.publishers.create
end

campaign = Db::PreachingCampaign.first

Db::Territory.find_each do |territory|
  factory.territory_assignments.create(
    campaign:,
    territory:
  )
end

campaign = Db::PreachingCampaign.last

Db::ApartmentBuildingTerritory.find_each do |territory|
  factory.territory_assignments.create(
    campaign:,
    territory:
  )
end
