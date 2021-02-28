# frozen_string_literal: true

class TestFactories
  def users
    @users ||= UserFactory.new(self)
  end

  def meetings
    @meetings ||= Db::MeetingAttendance::MeetingFactory.new(self)
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

  class Db::MeetingAttendance::MeetingFactory < Factory
    def attributes(overrides = {})
      { title: "Meeting-#{seq}" }.merge(overrides)
    end
  end
end
