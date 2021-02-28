# frozen_string_literal: true

class TestFactories
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
end
