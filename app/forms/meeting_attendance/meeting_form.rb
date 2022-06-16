# frozen_string_literal: true

module MeetingAttendance
  class MeetingForm < BaseForm
    delegate :title, :title=, to: :@record
    validates :title, presence: true

    def params=(params)
      self.attributes = params.require(:meeting).permit(:title)
    end
  end
end
