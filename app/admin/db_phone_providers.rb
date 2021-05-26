# frozen_string_literal: true

ActiveAdmin.register Db::PhoneProvider do
  menu parent: I18n.t('views.menu.others')
  permit_params :name
end
