# frozen_string_literal: true

class PublicTalks::TalksController < ApplicationController
  def index
    talks = paginate(Db::PublicTalk.filter(params).with_dependencies)
    render PublicTalks::Talks::IndexPageComponent.new(talks)
  end

  def show
    talk = Db::PublicTalk.find(params[:id])
    render PublicTalks::Talks::ShowPageComponent.new(talk)
  end

  def new
    talk = Db::PublicTalk.new
    render PublicTalks::Talks::FormPageComponent.new(talk)
  end

  def create
    talk = Db::PublicTalk.new(attributes)

    if talk.save
      return redirect_to(action: :index, since: since_filter)
    end

    render PublicTalks::Talks::FormPageComponent.new(talk), status: :unprocessable_entity
  end

  def edit
    talk = Db::PublicTalk.find(params[:id])
    render PublicTalks::Talks::FormPageComponent.new(talk)
  end

  def update
    talk = Db::PublicTalk.find(params[:id])

    if talk.update(attributes)
      return redirect_to(action: :index, since: since_filter)
    end

    render PublicTalks::Talks::FormPageComponent.new(talk), status: :unprocessable_entity
  end

  def destroy
    talk = Db::PublicTalk.find(params[:id])
    talk.destroy
    redirect_to(action: :index, since: since_filter)
  end

  private

  def attributes
    params.require(:talk).permit(
      :congregation_id,
      :speaker_id,
      :date,
      :theme,
      :status,
      :special,
      :notes
    )
  end

  def since_filter
    MeetingWeek.new.first_day
  end
end
