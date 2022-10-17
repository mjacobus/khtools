# frozen_string_literal: true

class AddAccountIdToPreachingCampaigns < ActiveRecord::Migration[6.1]
  include AccountIdMigrationHelper

  def up
    add_account_ownership(:preaching_campaigns)

    # This was not created. My expectation of
    #   t.string :code, unique: true
    # was not met
    # remove_index(:preaching_campaigns, %i[code], unique: true)
    add_index(:preaching_campaigns, %i[account_id code], unique: true)
  end

  def down
    remove_index(:preaching_campaigns, %i[account_id code], unique: true)
    add_index(:preaching_campaigns, %i[code], unique: true)

    remove_account_ownership(:preaching_campaigns)
  end
end
