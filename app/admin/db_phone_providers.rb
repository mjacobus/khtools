# frozen_string_literal: true

ActiveAdmin.register Db::PhoneProvider do
  menu parent: 'Outros'
  permit_params :name
end
