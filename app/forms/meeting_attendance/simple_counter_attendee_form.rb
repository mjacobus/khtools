# frozen_string_literal: true

class MeetingAttendance::SimpleCounterAttendeeForm < BaseForm
  delegate :name, :name=, to: :@record
  validates :name, presence: true

  def params=(params)
    self.attributes = params.require(:attendee).permit(:name)
  end

  private

  def param_key
    'attendee'
  end
end
