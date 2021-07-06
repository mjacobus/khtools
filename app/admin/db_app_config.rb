# frozen_string_literal: true

ActiveAdmin.register Db::AppConfig do
  menu parent: I18n.t('views.menu.others')
  permit_params :key, :value

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :key, as: :select, collection: Db::AppConfig::KEYS
      f.input :value
    end
    f.actions
  end
end
