# frozen_string_literal: true

1.upto(10) do |num|
  Db::MeetingAttendance::Meeting.create!(title: "Meeting #{num}", created_at: num.days.ago)
end
