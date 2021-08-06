# frozen_string_literal: true

class Territories::TerritoriesController < ApplicationController
  include CrudController

  key :territory

  scope { model_class.all.with_dependencies.search(params) }

  component_class_template 'Territories::%{type}PageComponent'

  private

  def permitted_keys
    model_class.new.editable_attributes
  end

  def index_component(territories)
    Territories::IndexPageComponent.new(
      territories: territories,
      title: model_class.model_name.human,
      type: model_class.new.type_key.to_sym
    )
  end
end
