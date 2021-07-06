# frozen_string_literal: true

class CreateAppConfigs < ActiveRecord::Migration[6.1]
  def change
    create_table :app_configs do |t|
      t.string :key
      t.text :value

      t.timestamps
    end
    add_index :app_configs, :key, unique: true
  end
end
