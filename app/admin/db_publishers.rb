# frozen_string_literal: true

ActiveAdmin.register Db::Publisher do
  permit_params :name, :email, :phone, :gender, :group_id, :elder, :ministerial_servant, :pioneer,
                :address,
                :primary_emergency_contact_name, :primary_emergency_contact_phone_number,
                :secondary_emergency_contact_name, :secondary_emergency_contact_phone_number
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
      row :address
      row :primary_emergency_contact_name
      row :primary_emergency_contact_phone_number
      row :secondary_emergency_contact_name
      row :secondary_emergency_contact_phone_number
      row :gender do |publisher|
        publisher.gender == 'm' ? 'Masculino' : 'Feminino'
      end
      row :group
      row :elder
      row :ministerial_servant
      row :pioneer
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
      f.input :address
      f.input :primary_emergency_contact_name
      f.input :primary_emergency_contact_phone_number
      f.input :secondary_emergency_contact_name
      f.input :secondary_emergency_contact_phone_number
      f.input :gender, as: :select, collection: [%w[Masculino m], %w[Feminino f]]
      f.input :group, as: :select, collection: Db::FieldServiceGroup.order(:name).pluck(:name, :id)
      f.input :elder
      f.input :ministerial_servant
      f.input :pioneer
    end
    f.actions
  end
end
