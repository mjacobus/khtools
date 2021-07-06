# frozen_string_literal: true

class AddStatusToPublicTalk < ActiveRecord::Migration[6.1]
  def change
    add_column :public_talks, :status, :string, null: false, default: 'scheduled'
    remove_column :public_talks, :draft, :boolean, default: true
    add_index :public_talks, :status
  end
end
