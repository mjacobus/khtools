# frozen_string_literal: true

module Public
  class PublicTalksComponent < ApplicationComponent
    attr_reader :talks

    def initialize(talks)
      @talks = talks
    end
  end
end
