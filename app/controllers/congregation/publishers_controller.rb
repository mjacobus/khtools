# frozen_string_literal: true

module Congregation
  class PublishersController < ApplicationController
    include CrudController
    include AccountAwareCrudController

    key :publisher
    permit :name, :gender, :group_id, :elder, :ministerial_servant, :pioneer,
           :email, :phone, :address,
           :primary_emergency_contact_name, :primary_emergency_contact_phone_number,
           :secondary_emergency_contact_name, :secondary_emergency_contact_phone_number
    scope { current_account.publishers.order(:name) }
    component_class_template 'Congregation::Publishers::%{type}PageComponent'
  end
end
