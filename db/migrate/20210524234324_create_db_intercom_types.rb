# frozen_string_literal: true

class CreateDbIntercomTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :intercom_types do |t|
      t.string :name, unique: true, null: false
      t.text :description

      t.timestamps
    end
  end
end
