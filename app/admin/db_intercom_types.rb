# frozen_string_literal: true

ActiveAdmin.register Db::IntercomType do
  menu parent: 'Outros'
  config.sort_order = 'name_asc'
  permit_params :name, :description
end
