# frozen_string_literal: true

class PublicTalks::Talks::FilterComponent < ApplicationComponent
  attr_reader :filter_params

  def initialize(params)
    @filter_params = params
  end

  def action_url
    public_talks_talks_path
  end

  def speaker_selected?(speaker)
    speaker.id.to_s == params[:speaker_id]
  end

  def options_for_speaker
    Db::PublicSpeaker.all.order(:name)
  end
end
