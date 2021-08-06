# frozen_string_literal: true

class PublicTalks::SpeakersController < ApplicationController
  include CrudController

  key :speaker

  model_class Db::PublicSpeaker
  scope { Db::PublicSpeaker.with_dependencies.order(:name) }

  permit :name,
         :phone,
         :email,
         :congregation_id

  component_class_template 'PublicTalks::Speakers::%{type}PageComponent', use_key: false
end
