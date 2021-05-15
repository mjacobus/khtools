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

  def field_service_groups
    @field_service_groups ||= Db::FieldServiceGroupFactory.new(self)
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
end
