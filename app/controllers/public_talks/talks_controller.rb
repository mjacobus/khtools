# frozen_string_literal: true

class PublicTalks::TalksController < ApplicationController
  include CrudController
  include AccountAwareCrudController

  key :talk

  scope { current_account.public_talks.search(params).with_dependencies }

  permit :congregation_id,
         :speaker_id,
         :date,
         :theme,
         :status,
         :special,
         :notes

  component_class_template 'PublicTalks::Talks::%{type}PageComponent', use_key: false

  private

  def find_scope
    current_account.public_talks
  end

  def redirect
    redirect_to(action: :index, since: MeetingWeek.new.first_day)
  end
end
