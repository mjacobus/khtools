# frozen_string_literal: true

class AddPrivilegesToPublishers < ActiveRecord::Migration[7.1]
  def change
    add_column :publishers, :elder, :boolean, default: false, null: false
    add_column :publishers, :ministerial_servant, :boolean, default: false, null: false
    add_column :publishers, :pioneer, :boolean, default: false, null: false
  end
end
