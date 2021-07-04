# frozen_string_literal: true

class MeetingWeek < Range
  def initialize(date = Time.zone.today)
    monday = date - date.days_to_week_start.days
    sunday = monday + 6.days
    super(monday, sunday)
  end

  def first_day
    self.begin
  end

  def last_day
    self.end
  end
end
