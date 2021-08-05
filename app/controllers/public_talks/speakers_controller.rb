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

  component_class_template 'PublicTalks::Speakers::%{type}PageComponent'

  private

  def form_component(record)
    component_class(:form).new(record)
  end

  def show_component(record)
    component_class(:show).new(record)
  end

  def index_component(record)
    component_class(:index).new(record)
  end
end
