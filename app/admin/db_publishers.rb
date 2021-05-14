# frozen_string_literal: true

ActiveAdmin.register Db::Publisher do
  menu label: I18n.t('active_admin.resources.db/publisher.menu_entry')
  permit_params :name, :email, :phone, :gender
end
