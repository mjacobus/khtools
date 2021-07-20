# frozen_string_literal: true

ActiveAdmin.register Db::PhoneListTerritory do
  menu parent: I18n.t('views.menu.territories')
  config.sort_order = 'name_asc'
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
    column :initial_phone_number do |territory|
      PhoneNumber.new(territory.initial_phone_number)
    end
    column :final_phone_number do |territory|
      PhoneNumber.new(territory.final_phone_number)
    end
    column :assignee
    column :assigned_at
    column :returned_at
    column :download_as do |territory|
      link_to :xls, xls_territories_phone_list_path(territory)
    end
    actions
  end

  show do
    attributes_table do
      row :name
      row :phone_provider
      row :initial_phone_number do |territory|
        PhoneNumber.new(territory.initial_phone_number)
      end
      row :final_phone_number do |territory|
        PhoneNumber.new(territory.final_phone_number)
      end

      row :numbers do |record|
        details do
          summary t("views.links.show")
          ul do
            record.phone_numbers.each do |number|
              li number
            end
          end
        end
      end
    end

    attributes_table title: t('active_admin.resources.db/territories.sections.files') do
      row :download_as do |territory|
        link_to :xls, xls_territories_phone_list_path(territory)
      end
    end

    attributes_table title: t('active_admin.resources.db/territories.sections.assignment') do
      row :assignee
      row :assigned_at
      row :returned_at
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :phone_provider
      f.input :initial_phone_number
      f.input :final_phone_number
    end
    inputs t('active_admin.resources.db/territories.sections.assignment') do
      input :assignee
      input :assigned_at
      input :returned_at
    end
    f.actions
  end
end
