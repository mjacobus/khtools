# frozen_string_literal: true

class CreateJoinTableTerritoriesContacts < ActiveRecord::Migration[6.1]
  def change
    create_join_table :territories, :contacts
  end
end
