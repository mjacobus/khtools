# frozen_string_literal: true

class CreateDbPublicSpeakers < ActiveRecord::Migration[6.1]
  def change
    create_table :public_speakers do |t|
      t.string :name, null: false
      t.string :phone
      t.string :email
      t.references :congregation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
