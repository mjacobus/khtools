# frozen_string_literal: true

class PublicTalks::SpeakersController < ApplicationController
  include CrudController
  include AccountAwareCrudController

  key :speaker

  scope { current_account.public_speakers.with_dependencies.order(:name) }

  permit :name,
         :phone,
         :email,
         :congregation_id

  component_class_template 'PublicTalks::Speakers::%{type}PageComponent', use_key: false

  private

  def find_scope
    current_account.public_speakers
  end
end
