# frozen_string_literal: true

class TestFactories
  def users
    @users ||= UserFactory.new(self)
  end

  def meetings
    @meetings ||= Db::MeetingAttendance::MeetingFactory.new(self)
  end

  def attendees
    @attendees ||= Db::MeetingAttendance::SimpleCounterAttendeeFactory.new(self)
  end

  def publishers
    @publishers ||= Db::PublisherFactory.new(self)
  end

  def preaching_methods
    @preaching_methods ||= Db::PreachingMethodFactory.new(self)
  end

  def preaching_campaigns
    @preaching_campaigns ||= Db::PreachingCampaignFactory.new(self)
  end

  def preaching_campaign_assignments
    @preaching_campaign_assignments ||= Db::PreachingCampaignAssignmentFactory.new(self)
  end

  def territory_areas
    @territory_areas ||= Db::TerritoryAreaFactory.new(self)
  end

  def letter_box_types
    @letter_box_types ||= Db::LetterBoxTypeFactory.new(self)
  end

  def intercom_types
    @intercom_types ||= Db::IntercomTypeFactory.new(self)
  end

  def territories
    @territories ||= Db::RegularTerritoryFactory.new(self)
  end

  def phone_list_territories
    @phone_list_territories ||= Db::PhoneListTerritoryFactory.new(self)
  end

  def apartment_building_territories
    @apartment_building_territories ||= Db::ApartmentBuildingTerritoryFactory.new(self)
  end

  def field_service_groups
    @field_service_groups ||= Db::FieldServiceGroupFactory.new(self)
  end

  def phone_providers
    @phone_providers ||= Db::PhoneProviderFactory.new(self)
  end

  class Factory
    attr_reader :factories

    def initialize(factories)
      @factories = factories
      @sequency = 0
    end

    def sequency
      @sequency += 1
    end

    def seq
      sequency
    end

    def create(overrides = {})
      model_class.create!(attributes.merge(overrides))
    end

    def build(overrides = {})
      model_class.new(attributes.merge(overrides))
    end

    private

    def model_class
      @model_class ||= self.class.to_s.sub('TestFactories::', '').sub('Factory', '').constantize
    end
  end

  class UserFactory < Factory
    def attributes(overrides = {})
      { name: "User-#{seq}" }.merge(overrides)
    end
  end

  class Db::PublisherFactory < Factory
    def attributes(overrides = {})
      {
        name: "User-#{seq}",
        gender: 'm',
        group: overrides[:group] || factories.field_service_groups.create
      }.merge(overrides)
    end
  end

  class Db::PhoneListTerritoryFactory < Factory
    def attributes(overrides = {})
      {
        name: "PhoneList-#{seq}",
        initial_phone_number: 5_199_990_000 + seq,
        final_phone_number: 5_199_990_000 + seq,
        phone_provider: overrides[:phone_provider] || factories.phone_providers.create
      }.merge(overrides)
    end
  end

  class Db::ApartmentBuildingTerritoryFactory < Factory
    def attributes(overrides = {})
      {
        name: "PhoneList-#{seq}"
      }.merge(overrides)
    end
  end

  class Db::RegularTerritoryFactory < Factory
    def attributes(overrides = {})
      {
        name: "Territory-#{seq}"
      }.merge(overrides)
    end
  end

  class Db::FieldServiceGroupFactory < Factory
    def attributes(overrides = {})
      { name: "group-#{seq}" }.merge(overrides)
    end
  end

  class Db::MeetingAttendance::MeetingFactory < Factory
    def attributes(overrides = {})
      { title: "Meeting-#{seq}" }.merge(overrides)
    end
  end

  class Db::MeetingAttendance::SimpleCounterAttendeeFactory < Factory
    def attributes(overrides = {})
      {
        name: "Attendee-#{seq}",
        meeting: overrides[:meeting] || factories.meetings.create
      }.merge(overrides)
    end
  end

  class Db::PreachingCampaignFactory < Factory
    def attributes(overrides = {})
      {
        code: "code-#{seq}",
        name: "Campaign-#{seq}"
      }.merge(overrides)
    end
  end

  class Db::PreachingCampaignAssignmentFactory < Factory
    def attributes(overrides = {})
      {
        campaign: overrides[:campaign] || factories.preaching_campaigns.create,
        territory: overrides[:territory] || factories.territories.create,
        assignee: overrides[:assignee] || factories.publishers.create,
        assigned_at: Time.zone.today
      }.merge(overrides)
    end
  end

  class Db::PreachingMethodFactory < Factory
    def attributes(overrides = {})
      {
        name: "PrechingMethod-#{seq}"
      }.merge(overrides)
    end
  end

  class Db::TerritoryAreaFactory < Factory
    def attributes(overrides = {})
      {
        name: "Area-#{seq}"
      }.merge(overrides)
    end
  end

  class Db::IntercomTypeFactory < Factory
    def attributes(overrides = {})
      {
        name: "IntercomType-#{seq}"
      }.merge(overrides)
    end
  end

  class Db::LetterBoxTypeFactory < Factory
    def attributes(overrides = {})
      {
        name: "LetterBoxType-#{seq}"
      }.merge(overrides)
    end
  end

  class Db::PhoneProviderFactory < Factory
    def attributes(overrides = {})
      {
        name: "Provider-#{seq}"
      }.merge(overrides)
    end
  end
end
