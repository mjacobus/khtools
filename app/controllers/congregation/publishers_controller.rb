# frozen_string_literal: true

module Congregation
  class PublishersController < ApplicationController
    include CrudController
    include AccountAwareCrudController

    key :publisher
    permit :name, :gender, :group_id
    scope { current_account.publishers.order(:name) }
    component_class_template 'Congregation::Publishers::%{type}PageComponent'
  end
end
