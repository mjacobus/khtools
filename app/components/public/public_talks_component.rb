# frozen_string_literal: true

class Public::PublicTalksComponent < ApplicationComponent
  attr_reader :talks

  def initialize(talks)
    @talks = talks
  end
end
