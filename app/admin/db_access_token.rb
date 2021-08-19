# frozen_string_literal: true

ActiveAdmin.register Db::AccessToken do
  menu parent: I18n.t('views.menu.others')
  permit_params :resource, :token, :expires_at
end
