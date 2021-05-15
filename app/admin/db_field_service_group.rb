# frozen_string_literal: true

ActiveAdmin.register Db::FieldServiceGroup do
  permit_params :name
  config.sort_order = 'name_asc'

  index do
    selectable_column
    column :name
    column :publishers do |group|
      group.publishers.count
    end
    actions
  end

  show do
    attributes_table do
      row :name
      row :publishers do |group|
        group.publishers.count
      end
      row :created_at
      row :updated_at
    end
  end
end
