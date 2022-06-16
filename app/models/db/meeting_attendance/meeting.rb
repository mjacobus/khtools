# frozen_string_literal: true

module Db
  module MeetingAttendance
    class Meeting < ApplicationRecord
      has_many :attendees,
               class_name: 'Db::MeetingAttendance::SimpleCounterAttendee',
               dependent: :destroy

      validates :title, presence: true

      scope :by_creation_date, -> { order(created_at: :desc) }

      def number_of_attendees
        attendees.sum(:quantity)
      end
    end
  end
end
