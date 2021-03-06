# frozen_string_literal: true

ActiveAdmin.register Db::Publisher do
  permit_params :name, :email, :phone, :gender, :group_id
  config.sort_order = 'name_asc'

  index do
    selectable_column
    column :name
    column :group
    actions
  end

  show do
    attributes_table do
      row :name
      row :email
      row :phone
      row :gender do |publisher|
        publisher.gender == 'm' ? 'Masculino' : 'Feminino'
      end
      row :group
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :email
      f.input :phone
      f.input :gender, as: :select, collection: [%w[Masculino m], %w[Feminino f]]
      f.input :group, as: :select, collection: Db::FieldServiceGroup.order(:name).pluck(:name, :id)
    end
    f.actions
  end
end
