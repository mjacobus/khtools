# frozen_string_literal: true

class PublicTalks::CongregationsController < ApplicationController
  include CrudController

  key :congregation

  model_class Db::Congregation
  scope { Db::Congregation.order(:name) }

  permit :name,
         :address,
         :primary_contact_person,
         :primary_contact_phone,
         :primary_contact_email,
         :weekend_meeting_time,
         :local

  component_class_template 'Congregations::%{type}PageComponent', use_key: false
end
