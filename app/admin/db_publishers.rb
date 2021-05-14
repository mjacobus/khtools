# frozen_string_literal: true

ActiveAdmin.register Db::Publisher do
  menu label: I18n.t('active_admin.resources.db/publisher.menu_entry')
  permit_params :name, :email, :phone, :gender

  index do
    selectable_column
    column :name
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
    end
    f.actions
  end
end
