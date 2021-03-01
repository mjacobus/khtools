# frozen_string_literal: true

class MeetingAttendance::MeetingsController < ApplicationController
  def index
    @meetings = Db::MeetingAttendance::Meeting.by_creation_date
  end

  def new
    @form = form.new(model.new)
  end

  def edit
    @form = form.new(find_meeting)
  end

  def create
    @form = form.new(model.new)
    @form.params = params

    if @form.save
      return redirect_to(meeting_attendance_meetings_url)
    end

    render :new, status: :unprocessable_entity
  end

  def update
    @form = form.new(find_meeting)
    @form.params = params

    if @form.save
      return redirect_to(meeting_attendance_meetings_url)
    end

    render :edit, status: :unprocessable_entity
  end

  def destroy
    @form = form.new(find_meeting)
    @form.destroy
    redirect_to meeting_attendance_meetings_url
  end

  private

  def model
    Db::MeetingAttendance::Meeting
  end

  def form
    MeetingAttendance::MeetingForm
  end

  def find_meeting
    model.find(params[:id])
  end
end
