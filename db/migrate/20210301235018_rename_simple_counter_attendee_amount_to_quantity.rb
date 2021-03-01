# frozen_string_literal: true

class RenameSimpleCounterAttendeeAmountToQuantity < ActiveRecord::Migration[6.1]
  def change
    rename_column :ma_simple_counter_attendees, :amount, :quantity
  end
end
