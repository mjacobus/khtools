# frozen_string_literal: true

class AddContactDetailsToPublishers < ActiveRecord::Migration[7.1]
  def change
    add_column :publishers, :address, :string
    add_column :publishers, :primary_emergency_contact_name, :string
    add_column :publishers, :primary_emergency_contact_phone_number, :string
    add_column :publishers, :secondary_emergency_contact_name, :string
    add_column :publishers, :secondary_emergency_contact_phone_number, :string
  end
end
