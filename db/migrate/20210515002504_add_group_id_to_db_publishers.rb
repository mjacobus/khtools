# frozen_string_literal: true

class AddGroupIdToDbPublishers < ActiveRecord::Migration[6.1]
  def change
    add_reference :publishers, :group, foreign_key: { to_table: :field_service_groups }
  end
end
