# frozen_string_literal: true

ActiveAdmin.register Db::ApartmentBuildingTerritory do
  menu parent: 'Territórios'
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
    attributes_table do
      row :name
      row :building_name
      row :address
      row :area
      row :territory
      row :has_a_roof
      row :number_of_apartments
      row :apartments

      row :intercom_type
      row :letter_box_type

      row :primary_preaching_method
      row :secondary_preaching_method
      row :tertiary_preaching_method
      row :notes

      row :assignee
      row :assigned_at
      row :returned_at

      row :created_at
      row :updated_at
    end
  end

  form do |_f|
    semantic_errors
    inputs do
      inputs t('active_admin.resources.db/apartment_building_territory.sections.building_inputs') do
        input :territory, as: :select,
                          collection: Db::RegularTerritory.order(:name).pluck(:name, :id)
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
        'active_admin.resources.db/apartment_building_territory.sections.preaching_methods'
      ) do
        input :primary_preaching_method
        input :secondary_preaching_method
        input :tertiary_preaching_method
      end

      inputs t('active_admin.resources.db/apartment_building_territory.sections.assignment') do
        input :assignee
        input :assigned_at
        input :returned_at
      end
    end
    actions
  end
end
