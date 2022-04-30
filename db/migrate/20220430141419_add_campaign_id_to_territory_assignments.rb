# frozen_string_literal: true

class AddCampaignIdToTerritoryAssignments < ActiveRecord::Migration[6.1]
  def change
    add_reference :territory_assignments, :campaign, null: true,
                                                     foreign_key: { to_table: :preaching_campaigns }
  end
end
