# frozen_string_literal: true

module Congregation
  class PublishersController < ApplicationController
    include CrudController
    key :publisher
    permit :name, :gender, :group_id
    scope { Db::Publisher.order(:name) }
    component_class_template 'Congregation::Publishers::%{type}PageComponent'
  end
end
