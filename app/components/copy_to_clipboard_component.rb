# frozen_string_literal: true

class CopyToClipboardComponent < ApplicationComponent
  attr_reader :selector

  def initialize(selector: nil)
    @selector = selector
  end
end
