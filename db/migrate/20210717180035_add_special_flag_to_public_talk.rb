# frozen_string_literal: true

class AddSpecialFlagToPublicTalk < ActiveRecord::Migration[6.1]
  def change
    add_column :public_talks, :special, :boolean, default: false
  end
end
