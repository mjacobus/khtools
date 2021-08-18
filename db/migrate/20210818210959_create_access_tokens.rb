# frozen_string_literal: true

class CreateAccessTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :access_tokens do |t|
      t.string :resource
      t.string :token
      t.datetime :expires_at

      t.timestamps
    end
    add_index :access_tokens, :resource
  end
end
