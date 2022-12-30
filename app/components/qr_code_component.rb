# frozen_string_literal: true

class QrCodeComponent < ApplicationComponent
  attr_reader :size

  def initialize(value)
    @value = value
    @size = 2
  end

  def with_size(size)
    @size = size
    self
  end

  def render?
    @value.present?
  end

  def code
    @code ||= RQRCode::QRCode.new(@value)
  end
end
