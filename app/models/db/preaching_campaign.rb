# frozen_string_literal: true

class Db::PreachingCampaign < ApplicationRecord
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
end
