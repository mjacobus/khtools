# frozen_string_literal: true

# The service year runs from September 1st to August 31st of the following year.
# It is named after the year it starts in: ServiceYear.new(2025) covers
# 2025-09-01..2026-08-31 and is labelled "2025/2026".
class ServiceYear < Range
  FIRST_MONTH = 9
  LAST_MONTH = FIRST_MONTH - 1
  ACCEPTED_YEARS = (1900..2200)

  delegate :year, to: :first_day

  def self.current(today = Time.zone.today)
    containing(today)
  end

  def self.containing(date)
    date = date.in_time_zone.to_date
    new(date.month >= FIRST_MONTH ? date.year : date.year - 1)
  end

  # Falls back to the current service year when the value is not a plausible
  # year. The fallback is only built when it is actually needed.
  def self.from_param(value, fallback: nil)
    year = Integer(value.to_s, exception: false)

    if year && ACCEPTED_YEARS.cover?(year)
      return new(year)
    end

    fallback || current
  end

  def initialize(year)
    year = Integer(year)
    super(Date.new(year, FIRST_MONTH, 1), Date.new(year + 1, LAST_MONTH, -1))
  end

  def first_day
    self.begin
  end

  def last_day
    self.end
  end

  def starts_at
    first_day.beginning_of_day
  end

  def ends_at
    last_day.end_of_day
  end

  def label
    "#{year}/#{year + 1}"
  end

  def to_param
    year.to_s
  end

  def to_s
    label
  end

  def previous
    self.class.new(year - 1)
  end

  def following
    self.class.new(year + 1)
  end
end
