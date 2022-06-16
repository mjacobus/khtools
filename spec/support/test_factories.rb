# frozen_string_literal: true

class TestFactories
  def users
    @users ||= UserFactory.new(self)
  end

  def contacts
    @contacts ||= Db::ContactFactory.new(self)
  end

  def congregations
    @congregations ||= Db::CongregationFactory.new(self)
  end

  def public_talks
    @public_talks ||= Db::PublicTalkFactory.new(self)
  end

  def public_speakers
    @public_speakers ||= Db::PublicSpeakerFactory.new(self)
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

  def territory_assignments
    @territory_assignments ||= Db::TerritoryAssignmentFactory.new(self)
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

  def commercial_territories
    @commercial_territories ||= Db::CommercialTerritoryFactory.new(self)
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

    def next_sequency
      @sequency += 1
    end

    def sequency
      @sequency ||= 0
    end

    def random
      model_class.order('RANDOM()').first
    end

    def random_or_create(overrides = {})
      random || create(overrides)
    end

    def seq
      sequency
    end

    def create(overrides = {})
      next_sequency
      model_class.create!(attributes(overrides))
    end

    def build(overrides = {})
      next_sequency
      model_class.new(attributes(overrides))
    end

    private

    def model_class
      @model_class ||= self.class.to_s.sub('TestFactories::', '').sub('Factory', '').constantize
    end

    def file_upload(file_name)
      file_path = Rails.root.join("spec/fixtures/#{file_name}")
      Rack::Test::UploadedFile.new(file_path)
    end
  end

  class UserFactory < Factory
    def attributes(overrides = {})
      { name: "User-#{seq}" }.merge(overrides)
    end
  end

  module Db
    class PublicSpeakerFactory < Factory
      def attributes(overrides = {})
        {
          name: "Br. John #{seq}",
          phone: "(51) 1234-123#{seq}",
          email: "person#{seq}@email.com",
          congregation_id: overrides[:congregation]&.id ||
            overrides[:congregation_id] ||
            factories.congregations.random_or_create.id
        }.merge(overrides)
      end
    end
  end

  module Db
    class PublicTalkFactory < Factory
      def attributes(overrides = {})
        {
          theme: seq,
          date: seq.days.from_now.round,
          speaker_id: overrides[:speaker]&.id ||
            overrides[:speaker_id] ||
            factories.public_speakers.random_or_create.id,
          congregation_id: overrides[:congregation]&.id ||
            overrides[:congregation_id] ||
            factories.congregations.random_or_create.id
        }.merge(overrides)
      end
    end
  end

  module Db
    class CongregationFactory < Factory
      def attributes(overrides = {})
        {
          name: "Congregation-#{seq}",
          address: "Some street #{seq}",
          primary_contact_person: "Br. John #{seq}",
          primary_contact_phone: "(51) 1234-123#{seq}",
          primary_contact_email: "person#{seq}@email.com",
          weekend_meeting_time: "Saturday seq o'clock",
          local: false
        }.merge(overrides)
      end
    end
  end

  module Db
    class ContactFactory < Factory
      def attributes(overrides = {})
        {
          name: "Contact-#{seq}",
          email: "email#{seq}@example.com",
          address: "Some street #{seq}",
          phone: "(51) 1234-123#{seq}",
          phone2: "(51) 1234-123#{seq + 1}",
          notes: "Some notes for Contact-#{seq}"
        }.merge(overrides)
      end
    end
  end

  module Db
    class PublisherFactory < Factory
      def attributes(overrides = {})
        {
          name: "User-#{seq}",
          gender: 'm',
          group_id: overrides[:group]&.id ||
            overrides[:group_id] ||
            factories.field_service_groups.random_or_create.id
        }.merge(overrides)
      end
    end
  end

  module Db
    class PhoneListTerritoryFactory < Factory
      def attributes(overrides = {})
        {
          name: "PhoneList-#{seq}",
          initial_phone_number: 5_199_990_000 + seq,
          final_phone_number: 5_199_990_000 + seq,
          phone_provider: overrides[:phone_provider] || factories.phone_providers.random_or_create
        }.merge(overrides)
      end
    end
  end

  module Db
    class ApartmentBuildingTerritoryFactory < Factory
      def attributes(overrides = {})
        {
          name: "ApartmentBuilding-#{seq}",
          address: "Some address #{seq}"
        }.merge(overrides)
      end
    end
  end

  module Db
    class RegularTerritoryFactory < Factory
      def attributes(overrides = {})
        {
          name: "Territory-#{seq}",
          file: file_upload('sample_territory.jpg')
        }.merge(overrides)
      end
    end
  end

  module Db
    class CommercialTerritoryFactory < Factory
      def attributes(overrides = {})
        {
          name: "C-#{seq}"
        }.merge(overrides)
      end
    end
  end

  module Db
    class FieldServiceGroupFactory < Factory
      def attributes(overrides = {})
        { name: "group-#{seq}" }.merge(overrides)
      end
    end
  end

  module Db
    module MeetingAttendance
      class MeetingFactory < Factory
        def attributes(overrides = {})
          { title: "Meeting-#{seq}" }.merge(overrides)
        end
      end
    end
  end

  module Db
    module MeetingAttendance
      class SimpleCounterAttendeeFactory < Factory
        def attributes(overrides = {})
          {
            name: "Attendee-#{seq}",
            meeting: overrides[:meeting] || factories.meetings.random_or_create
          }.merge(overrides)
        end
      end
    end
  end

  module Db
    class PreachingCampaignFactory < Factory
      def attributes(overrides = {})
        {
          code: "code-#{seq}",
          name: "Campaign-#{seq}"
        }.merge(overrides)
      end
    end
  end

  module Db
    class TerritoryAssignmentFactory < Factory
      def attributes(overrides = {})
        {
          campaign: overrides[:campaign] || factories.preaching_campaigns.random_or_create,
          territory: overrides[:territory] || factories.territories.random_or_create,
          assignee: overrides[:assignee] || factories.publishers.random_or_create,
          assigned_at: Time.zone.today
        }.merge(overrides)
      end
    end
  end

  module Db
    class PreachingMethodFactory < Factory
      def attributes(overrides = {})
        {
          name: "PrechingMethod-#{seq}"
        }.merge(overrides)
      end
    end
  end

  module Db
    class TerritoryAreaFactory < Factory
      def attributes(overrides = {})
        {
          name: "Area-#{seq}"
        }.merge(overrides)
      end
    end
  end

  module Db
    class IntercomTypeFactory < Factory
      def attributes(overrides = {})
        {
          name: "IntercomType-#{seq}"
        }.merge(overrides)
      end
    end
  end

  module Db
    class LetterBoxTypeFactory < Factory
      def attributes(overrides = {})
        {
          name: "LetterBoxType-#{seq}"
        }.merge(overrides)
      end
    end
  end

  module Db
    class PhoneProviderFactory < Factory
      def attributes(overrides = {})
        {
          name: "Provider-#{seq}"
        }.merge(overrides)
      end
    end
  end
end
