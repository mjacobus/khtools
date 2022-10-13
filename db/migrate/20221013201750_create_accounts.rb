# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.string :congregation_name

      t.timestamps
    end
    add_index :accounts, :congregation_name, unique: true
  end
end
