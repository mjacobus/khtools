# frozen_string_literal: true

class PublicTalks::TalksController < ApplicationController
  include CrudController

  key :talk

  model_class Db::PublicTalk
  scope { |params| Db::PublicTalk.filter(params).with_dependencies }

  permit :congregation_id,
         :speaker_id,
         :date,
         :theme,
         :status,
         :special,
         :notes

  component_class_template 'PublicTalks::Talks::%{type}PageComponent', use_key: false

  private

  def redirect
    redirect_to(action: :index, since: MeetingWeek.new.first_day)
  end
end
