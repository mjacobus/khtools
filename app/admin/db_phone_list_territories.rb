# frozen_string_literal: true

ActiveAdmin.register Db::PhoneListTerritory do
  menu parent: 'Territórios'
  permit_params :name,
                :assigned_at,
                :returned_at,
                :type,
                :assignee_id,
                :phone_provider_id,
                :initial_phone_number,
                :final_phone_number

  index do
    selectable_column
    column :name
    column :phone_provider
    column :initial_phone_number
    column :final_phone_number
    column :assignee
    column :assigned_at
    column :returned_at
    actions
  end

  show do
    attributes_table do
      row :name
      row :phone_provider
      row :assigned_at
      row :returned_at
      row :assignee
      row :initial_phone_number
      row :final_phone_number
      row :numbers do |record|
        ul do
          record.phone_numbers.each do |number|
            li number
          end
        end
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :phone_provider
      f.input :initial_phone_number
      f.input :final_phone_number
      f.input :assigned_at
      f.input :returned_at
      f.input :assignee
    end
    f.actions
  end
end
