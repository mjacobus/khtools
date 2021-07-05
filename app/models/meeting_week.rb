# frozen_string_literal: true

class MeetingWeek < Range
  def initialize(date = Time.zone.today)
    monday = date.beginning_of_week.to_date
    sunday = date.end_of_week.to_date
    super(monday, sunday)
  end

  def first_day
    self.begin
  end

  def last_day
    self.end
  end

  def cover?(time)
    super(time.to_date)
  end

  def include?(time)
    super(time.to_date)
  end
end
