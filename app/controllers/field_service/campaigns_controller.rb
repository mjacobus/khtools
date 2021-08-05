# frozen_string_literal: true

class FieldService::CampaignsController < ApplicationController
  include CrudController

  key :campaign

  permit :code,
         :description,
         :name,
         :start_date,
         :end_date

  scope { Db::PreachingCampaign.order(created_at: :desc) }

  component_class_template 'FieldService::Campaigns::%{type}PageComponent'
end
