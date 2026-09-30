# frozen_string_literal: true

class AddUserToPublishers < ActiveRecord::Migration[7.1]
  def change
    add_reference :publishers, :user, foreign_key: true, index: { unique: true }
  end
end
