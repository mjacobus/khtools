# frozen_string_literal: true

ActiveAdmin.register Db::ApartmentBuildingTerritory do
  menu parent: I18n.t('views.menu.territories')
  config.sort_order = 'name_asc'
  permit_params :name,
                :assigned_at,
                :returned_at,
                :created_at,
                :updated_at,
                :assignee_id,
                :address,
                :building_name,
                :number_of_apartments,
                :has_a_roof,
                :intercom_type,
                :apartments,
                :notes,
                :territory_id,
                :area_id,
                :intercom_type_id,
                :letter_box_type_id,
                :primary_preaching_method_id,
                :secondary_preaching_method_id,
                :tertiary_preaching_method_id

  index do
    selectable_column
    column :name
    column :building_name
    column :territory
    column :number_of_apartments
    column :area
    column :assignee
    column :assigned_at
    column :returned_at
    actions
  end

  show do
    attributes_table title: t('active_admin.resources.db/territories.sections.building_inputs') do
      row :name
      row :building_name
      row :address
      row :area
      row :has_a_roof
      row :number_of_apartments
      row :intercom_type
      row :letter_box_type
      row :apartments
      row :notes
    end

    attributes_table title: t(
      'active_admin.resources.db/territories.sections.preaching_methods'
    ) do
      row :territory, as: :select,
                      collection: Db::RegularTerritory.order(:name).pluck(:name, :id)
      row :primary_preaching_method
      row :secondary_preaching_method
      row :tertiary_preaching_method
    end

    attributes_table title: t('active_admin.resources.db/territories.sections.assignment') do
      row :assignee
      row :assigned_at
      row :returned_at
    end
  end

  form do |_f|
    semantic_errors
    inputs t('active_admin.resources.db/territories.sections.building_inputs') do
      input :name
      input :building_name
      input :address
      input :area
      input :has_a_roof
      input :number_of_apartments
      input :intercom_type
      input :letter_box_type
      input :apartments
      input :notes
    end

    inputs t(
      'active_admin.resources.db/territories.sections.preaching_methods'
    ) do
      input :territory, as: :select,
        collection: Db::RegularTerritory.order(:name).pluck(:name, :id)
      input :primary_preaching_method
      input :secondary_preaching_method
      input :tertiary_preaching_method
    end

    inputs t('active_admin.resources.db/territories.sections.assignment') do
      input :assignee
      input :assigned_at
      input :returned_at
    end
    actions
  end
end
