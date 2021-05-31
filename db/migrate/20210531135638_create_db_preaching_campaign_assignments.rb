# frozen_string_literal: true

class CreateDbPreachingCampaignAssignments < ActiveRecord::Migration[6.1]
  def change
    create_table :preaching_campaign_assignments do |t|
      t.references :campaign, null: false, foreign_key: { to_table: :preaching_campaigns }
      t.references :territory, null: false, foreign_key: true
      t.references :assignee, null: true, foreign_key: { to_table: :publishers }
      t.date :assigned_at
      t.date :returned_at
      t.text :notes

      t.timestamps
    end

    add_index :preaching_campaign_assignments,
              %i[territory_id campaign_id],
              unique: true,
              name: 'preaching_campaign_assignments_uk'
  end
end
