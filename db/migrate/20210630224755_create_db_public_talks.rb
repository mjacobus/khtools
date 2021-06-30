# frozen_string_literal: true

class CreateDbPublicTalks < ActiveRecord::Migration[6.1]
  def change
    create_table :public_talks do |t|
      t.references :congregation, null: true, foreign_key: true
      t.integer :speaker_id, null: true
      t.string :talk
      t.boolean :legacy, default: false
      t.timestamp :date

      t.timestamps
    end

    add_foreign_key :public_talks, :public_speakers, column: :speaker_id
  end
end
