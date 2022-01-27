# frozen_string_literal: true

class MakeCongregationOptionalForPublicSpeakers < ActiveRecord::Migration[6.1]
  def change
    change_column_null :public_speakers, :congregation_id, true
  end
end
