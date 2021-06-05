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
      row :created_at
      row :updated_at
      row :publishers do |group|
        div do
          group.publishers.each do |publisher|
            div link_to(publisher.name, admin_db_publisher_path(publisher))
          end
        end
      end
    end
  end
end
