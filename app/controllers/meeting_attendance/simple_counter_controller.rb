# frozen_string_literal: true

class MeetingAttendance::SimpleCounterController < ApplicationController
  def index
    @form = form_class.new(meeting.attendees.build)
    @attendees = meeting.attendees.order(:name)
  end

  def create
    names.each do |name|
      attendee = meeting.attendees.build
      form = form_class.new(attendee)
      form.name = name
      form.save
    end
    redirect_to action: :index
  end

  def destroy
    attendee = meeting.attendees.find(params[:id])
    form_class.new(attendee).destroy
    redirect_to action: :index
  end

  private

  def meeting
    @meeting ||= Db::MeetingAttendance::Meeting.find(params[:meeting_id])
  end

  def form_class
    MeetingAttendance::SimpleCounterAttendeeForm
  end

  def names
    params[:attendee][:name].to_s.split(',').map do |name|
      name.strip.presence
    end.compact
  end
end
