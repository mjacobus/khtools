# frozen_string_literal: true

class AddDraftToPublicTalks < ActiveRecord::Migration[6.1]
  def change
    add_column :public_talks, :draft, :boolean, default: false
  end
end
