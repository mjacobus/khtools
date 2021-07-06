# frozen_string_literal: true

class PublicController < ApplicationController
  skip_before_action :require_authorization

  def public_talks
    talks = Db::PublicTalk.scheduled.since(MeetingWeek.new.first_day)
    render Public::PublicTalksComponent.new(talks)
  end
end
