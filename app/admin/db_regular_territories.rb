# frozen_string_literal: true

ActiveAdmin.register Db::RegularTerritory do
  menu parent: I18n.t('views.menu.territories')
  permit_params :name, :assignee_id
  config.sort_order = 'name_asc'

  index do
    selectable_column
    column :name
    column :assignee
    column :assigned_at
    column :returned_at
    actions
  end

  show do
    attributes_table do
      row :name
    end

    attributes_table title: t('active_admin.resources.db/territories.sections.assignment') do
      row :assignee
      row :assigned_at
      row :returned_at
    end
  end

  form do |_f|
    semantic_errors
    inputs do
      input :name
    end
    inputs t('active_admin.resources.db/territories.sections.assignment') do
      input :assignee
      input :assigned_at
      input :returned_at
    end
    actions
  end
end
