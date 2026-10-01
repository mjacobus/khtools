# frozen_string_literal: true

class PublicTalks::CongregationsController < ApplicationController
  include CrudController
  include AccountAwareCrudController

  key :congregation

  scope { current_account.congregations.order(:name) }

  permit :name,
         :address,
         :primary_contact_person,
         :primary_contact_phone,
         :primary_contact_email,
         :weekend_meeting_time,
         :local

  component_class_template 'Congregations::%{type}PageComponent', use_key: false
end
