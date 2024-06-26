# frozen_string_literal: true

class TestFactories
  def accounts
    @accounts ||= Db::AccountFactory.new(self)
  end

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

  def speakers
    public_speakers
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

  def groups
    field_service_groups
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

    def associations(associations, data)
      added_values = {}

      associations.each do |model|
        id_key = :"#{model}_id"

        if data.key?(model) || data.key?(id_key)
          next
        end

        added_values[id_key] = factories.send(model.to_s.pluralize).create.id
      end

      added_values
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

  class Db::AccountFactory < Factory
    def attributes(overrides = {})
      { congregation_name: "Congregation-#{seq}" }.merge(overrides)
    end
  end

  class UserFactory < Factory
    def attributes(overrides = {})
      {
        name: "User-#{seq}",
        avatar: 'https://lh3.googleusercontent.com/-QTW2nlN4-NU/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucnAmijxFSFomGTNwgC-PRjxi5qPVg/s96-c/photo.jpgend'
      }.merge(overrides).merge(associations([:account], overrides))
    end
  end

  class Db::PublicSpeakerFactory < Factory
    def attributes(overrides = {})
      {
        name: "Br. John #{seq}",
        phone: "(51) 1234-123#{seq}",
        email: "person#{seq}@email.com"
      }.merge(overrides).merge(associations([:congregation], overrides))
    end
  end

  class Db::PublicTalkFactory < Factory
    def attributes(overrides = {})
      {
        theme: seq,
        date: seq.days.from_now.round
      }.merge(overrides).merge(associations(%i[congregation speaker], overrides))
    end
  end

  class Db::CongregationFactory < Factory
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

  class Db::ContactFactory < Factory
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

  class Db::PublisherFactory < Factory
    def attributes(overrides = {})
      {
        name: "User-#{seq}",
        gender: 'm'
      }.merge(overrides).merge(associations(%i[account group], overrides))
    end
  end

  class Db::PhoneListTerritoryFactory < Factory
    def attributes(overrides = {})
      {
        name: "PhoneList-#{seq}",
        initial_phone_number: 5_199_990_000 + seq,
        final_phone_number: 5_199_990_000 + seq,
        phone_provider: overrides[:phone_provider] || factories.phone_providers.random_or_create
      }.merge(overrides).merge(associations([:account], overrides))
    end
  end

  class Db::ApartmentBuildingTerritoryFactory < Factory
    def attributes(overrides = {})
      {
        name: "ApartmentBuilding-#{seq}",
        address: "Some address #{seq}"
      }.merge(overrides).merge(associations([:account], overrides))
    end
  end

  class Db::RegularTerritoryFactory < Factory
    def attributes(overrides = {})
      {
        name: "Territory-#{seq}",
        file: file_upload('sample_territory.jpg')
      }.merge(overrides).merge(associations([:account], overrides))
    end
  end

  class Db::CommercialTerritoryFactory < Factory
    def attributes(overrides = {})
      {
        name: "C-#{seq}"
      }.merge(overrides).merge(associations([:account], overrides))
    end
  end

  class Db::FieldServiceGroupFactory < Factory
    def attributes(overrides = {})
      {
        name: "group-#{seq}"
      }.merge(overrides).merge(associations([:account], overrides))
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
        meeting: overrides[:meeting] || factories.meetings.random_or_create
      }.merge(overrides)
    end
  end

  class Db::PreachingCampaignFactory < Factory
    def attributes(overrides = {})
      {
        code: "code-#{seq}",
        name: "Campaign-#{seq}"
      }.merge(overrides).merge(associations([:account], overrides))
    end
  end

  class Db::TerritoryAssignmentFactory < Factory
    def attributes(overrides = {})
      {
        campaign: overrides[:campaign] || factories.preaching_campaigns.random_or_create,
        territory: overrides[:territory] || factories.territories.random_or_create,
        assignee: overrides[:assignee] || factories.publishers.random_or_create,
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
