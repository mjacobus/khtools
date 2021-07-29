# frozen_string_literal: true

class RecordAttributeComponent < ApplicationComponent
  def initialize(record)
    @record = record
  end

  def call
    render AttributeComponent.new(**options) do
      value
    end
  end

  private

  attr_reader :record

  def options
    {
      icon_name: icon_name,
      classes: bem
    }
  end
end
