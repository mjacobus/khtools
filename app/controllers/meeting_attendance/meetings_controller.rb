# frozen_string_literal: true

module MeetingAttendance
  class MeetingsController < ApplicationController
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

      return redirect_to(meeting_attendance_meetings_url) if @form.save

      render :new, status: :unprocessable_entity
    end

    def update
      @form = form.new(find_meeting)
      @form.params = params

      return redirect_to(meeting_attendance_meetings_url) if @form.save

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
end
