# frozen_string_literal: true

ActiveAdmin.register Db::RegularTerritory do
  menu parent: ['Territórios']
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
      row :assignee
      row :assigned_at
      row :returned_at
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :assigned_at
      f.input :returned_at
      f.input :assignee
    end
    f.actions
  end
end
