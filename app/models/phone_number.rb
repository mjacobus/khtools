# frozen_string_literal: true

class PhoneNumber
  def initialize(number)
    @number = number.to_s.gsub(/[^\d+]/, '').freeze
  end

  def unformatted
    @number
  end

  def to_s
    @to_s ||= formatted
  end

  private

  def formatted
    [
      '(',
      @number[0..1],
      ')',
      ' ',
      @number[2..6],
      '-',
      @number[7..@number.length]
    ].flatten.join
  end
end
