# frozen_string_literal: true

class CreatePublishers < ActiveRecord::Migration[6.1]
  def change
    create_table :publishers do |t|
      t.string :name, null: false, index: true
      t.string :email, index: true
      t.string :phone
      t.string :gender, length: 1

      t.timestamps
    end
  end
end
