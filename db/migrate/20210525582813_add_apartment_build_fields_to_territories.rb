# frozen_string_literal: true

class AddApartmentBuildFieldsToTerritories < ActiveRecord::Migration[6.1]
  def change
    add_column :territories, :address, :string
    add_column :territories, :building_name, :string
    add_reference :territories, :territory_area, foreign_key: true
    add_column :territories, :number_of_apartments, :integer
    add_column :territories, :has_a_roof, :boolean, index: true, null: true
    add_column :territories, :intercom_type, :string, index: true
    add_column :territories, :letter_box_type, :string, index: true
    add_column :territories, :apartments, :text
    add_column :territories, :notes, :text

    add_reference :territories, :territory, foreign_key: { to_table: :territories }
    add_reference :territories, :area, foreign_key: { to_table: :territory_areas }

    add_reference :territories, :intercom_type,
                  foreign_key: { to_table: :intercom_types }

    add_reference :territories, :primary_preaching_method,
                  foreign_key: { to_table: :preaching_methods }
    add_reference :territories, :secondary_preaching_method,
                  foreign_key: { to_table: :preaching_methods }
    add_reference :territories, :tertiary_preaching_method,
                  foreign_key: { to_table: :preaching_methods }
  end
end
