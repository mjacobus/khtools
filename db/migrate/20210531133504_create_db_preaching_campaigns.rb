# frozen_string_literal: true

class CreateDbPreachingCampaigns < ActiveRecord::Migration[6.1]
  def change
    create_table :preaching_campaigns do |t|
      t.string :code, unique: true
      t.string :name
      t.text :description
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
