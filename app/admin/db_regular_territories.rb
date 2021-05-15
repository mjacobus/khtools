# frozen_string_literal: true

ActiveAdmin.register Db::RegularTerritory do
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
