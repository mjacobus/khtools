# frozen_string_literal: true

class PublicTalks::Talks::FilterComponent < ApplicationComponent
  attr_reader :filter_params

  def initialize(params)
    @filter_params = params
  end

  def action_url
    public_talks_talks_path
  end

  def label_for_since
    attribute_name(Db::PublicTalk, :since)
  end

  def label_for_speaker
    Db::PublicSpeaker.model_name.human
  end

  def label_for_congregation
    Db::Congregation.model_name.human
  end

  def label_for_theme
    attribute_name(Db::PublicTalk, :theme)
  end

  def speaker_selected?(speaker)
    speaker.id.to_s == params[:speaker_id]
  end

  def congregation_selected?(congregation)
    congregation.id.to_s == params[:congregation_id]
  end

  def since_selected?(since)
    since.to_s == params[:since]
  end

  def theme_selected?(theme)
    theme.number.to_s == params[:theme]
  end

  def options_for_speaker
    Db::PublicSpeaker.all.order(:name).with_dependencies
  end

  def options_for_congregation
    Db::Congregation.all.order(:name)
  end

  def options_for_theme
    PublicTalks::Themes.new.all
  end

  def options_for_since
    options = [MeetingWeek.new.first_day]
    0.upto(5).each do |num|
      options.push(num.years.ago.beginning_of_year.to_date)
    end
    options
  end
end
