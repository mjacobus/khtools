# frozen_string_literal: true

ActiveAdmin.register Db::PreachingCampaign do
  menu parent: I18n.t('views.menu.others')
  permit_params :code, :name, :description, :start_date, :end_date
end
