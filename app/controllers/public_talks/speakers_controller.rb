# frozen_string_literal: true

class PublicTalks::SpeakersController < ApplicationController
  def index
    speakers = paginate(Db::PublicSpeaker.all.order(:name))
    render PublicTalks::Speakers::IndexPageComponent.new(speakers)
  end

  def show
    speaker = Db::PublicSpeaker.find(params[:id])
    render PublicTalks::Speakers::ShowPageComponent.new(speaker)
  end

  def new
    speaker = Db::PublicSpeaker.new
    render PublicTalks::Speakers::FormPageComponent.new(speaker)
  end

  def create
    speaker = Db::PublicSpeaker.new(attributes)

    if speaker.save
      return redirect_to(action: :index)
    end

    render PublicTalks::Speakers::FormPageComponent.new(speaker), status: :unprocessable_entity
  end

  def edit
    speaker = Db::PublicSpeaker.find(params[:id])
    render PublicTalks::Speakers::FormPageComponent.new(speaker)
  end

  def update
    speaker = Db::PublicSpeaker.find(params[:id])

    if speaker.update(attributes)
      return redirect_to(action: :index)
    end

    render PublicTalks::Speakers::FormPageComponent.new(speaker), status: :unprocessable_entity
  end

  def destroy
    speaker = Db::PublicSpeaker.find(params[:id])
    speaker.destroy
    redirect_to(action: :index)
  end

  private

  def attributes
    params.require(:speaker).permit(
      :name,
      :phone,
      :email,
      :congregation_id
    )
  end
end
