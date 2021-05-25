# frozen_string_literal: true

class CreateDbLetterBoxTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :letter_box_types do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
