# frozen_string_literal: true

ActiveAdmin.register User do
  permit_params :master, :enabled, :account_id, controller_accesses: []

  action_item :impersonate, only: :show do
    link_to 'Impersonate', impersonate_admin_user_path(user), method: :post
  end

  # Add a route for impersonation
  member_action :impersonate, method: :post do
    session[:user_id] = resource.id
    redirect_to root_path, notice: "You are now impersonating #{resource.email}"
  end

  # Add a route to stop impersonation
  collection_action :stop_impersonating, method: :post do
    stop_impersonating_user
    redirect_to admin_users_path, notice: 'Stopped impersonating the user' # rubocop:disable Rails/I18nLocaleTexts
  end

  index do
    selectable_column
    column :name
    column :email
    column :congregation_name
    column :enabled
    column :master
    column :updated_at
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name, input_html: { disabled: true }
      f.input :email, input_html: { disabled: true }
      f.input :account
      f.input :master
      f.input :enabled
      f.input :controller_accesses, as: :check_boxes,
                                    collection: ControllerAcl.controller_actions_for_acl
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :email
      row :avatar do |user|
        image_tag user.avatar
      end
      row :master
      row :enabled
      row :permission_config
      row :created_at
      row :updated_at
      row :controller_accesses do |user|
        ul do
          user.controller_accesses.sort.each do |controller_action|
            li controller_action
          end
        end
      end
    end
  end
end
