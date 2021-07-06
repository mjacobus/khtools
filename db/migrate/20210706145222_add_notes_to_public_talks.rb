# frozen_string_literal: true

class AddNotesToPublicTalks < ActiveRecord::Migration[6.1]
  def change
    add_column :public_talks, :notes, :text
  end
end
