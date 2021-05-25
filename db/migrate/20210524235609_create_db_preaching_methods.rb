# frozen_string_literal: true

class CreateDbPreachingMethods < ActiveRecord::Migration[6.1]
  def change
    create_table :preaching_methods do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
