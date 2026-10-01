# frozen_string_literal: true

class PublicController < ApplicationController
  skip_before_action :require_authorization

  def public_talks
    account = Db::Account.find(params[:account_id])
    talks = account.public_talks.upcoming.local.since(MeetingWeek.new.first_day)
    render Public::PublicTalksComponent.new(talks)
  end

  def default_public_talks
    redirect_to(public_talks_path(Db::Account.order(:id).first!))
  end
end
