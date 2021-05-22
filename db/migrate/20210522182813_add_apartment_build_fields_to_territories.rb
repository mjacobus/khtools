# frozen_string_literal: true

class AddApartmentBuildFieldsToTerritories < ActiveRecord::Migration[6.1]
  def change
    create_table :territory_areas do |t|
      t.string :name, unique: true
      t.string :type

      t.timestamps
    end

    add_column :territories, :address, :string
    add_reference :territories, :territory_area, null: true, foreign_key: true
    add_column :territories, :number_of_apartments, :integer
    add_column :territories, :primary_preaching_method, :string
    add_column :territories, :secundary_preaching_method, :string
    add_column :territories, :tertiary_preaching_method, :string
    add_column :territories, :has_a_roof, :boolean
    add_column :territories, :intercom_type, :string
    add_column :territories, :letter_box_type, :string
    add_column :territories, :apartments, :text
    add_column :territories, :notes, :text

    add_reference :territories, :territory, foreign_key: { to_table: :territories }
  end
end
